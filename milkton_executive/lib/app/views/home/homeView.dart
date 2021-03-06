import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:milkton_executive/app/views/login/loginScreen.dart';
import 'package:milkton_executive/app/views/productList/productList.dart';
import 'package:milkton_executive/app/widgets/orderCard.dart';
import 'package:milkton_executive/app/widgets/table.dart';
import 'package:milkton_executive/configs/date.dart';
import 'package:milkton_executive/constants/color_constant.dart';
import 'package:milkton_executive/graphql/orderQuery.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeView extends StatefulWidget {
  @override
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final TextEditingController _searchQuery = TextEditingController();
  String query = '';
  bool searchIconTap = false;
  String executiveID;
  String lastName;
  String firstName;
  List orderList = [];
  List productList = [];
  getProductList(List orderList) {
    productList = [];
    for (int i = 0; i < orderList.length; i++) {
      for (int j = 0; j < orderList[i]["items"].length; j++) {
        var currentOrder = {
          "productID": orderList[i]["items"][j]["productID"],
          "quantity": orderList[i]["items"][j]["quantity"],
          "status": orderList[i]["status"],
        };
        var requiredProduct = productList.firstWhere(
            (element) =>
                element["productID"] == currentOrder["productID"] &&
                element["status"] == currentOrder["status"],
            orElse: () => null);
        if (requiredProduct != null) {
          requiredProduct["quantity"] += currentOrder["quantity"];
        } else {
          productList.add(currentOrder);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: searchIconTap
            ? TextField(
                controller: _searchQuery,
                onChanged: (value) {
                  setState(() {
                    query = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search by Name or Phone',
                ),
              )
            : Text('Home'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: searchIconTap ? Icon(Icons.arrow_back) : Icon(Icons.search),
              onPressed: () {
                setState(() {
                  searchIconTap = !searchIconTap;
                  _searchQuery.clear();
                  query = '';
                });
              },
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: kPrimaryColor,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 40.0,
                    foregroundImage: NetworkImage(
                      "https://github.com/GEPTON-INFOTECH/GEPTON-INFOTECH/raw/main/branding/xori.jpeg",
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    'Hey????, $firstName $lastName',
                    style: TextStyle(color: kWhite, fontSize: 20.0),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.shop),
              onTap: () {
                getProductList(orderList);
                Get.to(ProductList(
                  productList: productList,
                ));
              },
              title: Text(
                'Product List',
                style: TextStyle(fontSize: 16.0),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text(
                'Profile',
                style: TextStyle(fontSize: 16.0),
              ),
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text(
                'Log Out',
                style: TextStyle(fontSize: 16.0),
              ),
              onTap: () {
                _logout();
              },
            ),
          ],
        ),
      ),
      body: Query(
          options: QueryOptions(
              document: gql(orderForToday), variables: {"id": executiveID}),
          builder: (QueryResult result,
              {VoidCallback refetch, FetchMore fetchMore}) {
            if (result.isLoading) {
              return Center(child: Text('Loading....'));
            }

            if (result.hasException) {
              return Center(
                child: Text('Please check your Internet Connection'),
              );
            }
            if (result.data["executive"] == null) {
              return Center(
                child: Text('No Orders for you'),
              );
            }
            if (result.data["executive"] != null) {
              orderList = result.data["executive"]["ordersForToday"];
              List queryList = query != ''
                  ? orderList
                      .where((element) =>
                          element["customer"]["firstName"]
                              .toString()
                              .toLowerCase()
                              .contains(query.toLowerCase()) ||
                          element["customer"]["lastName"]
                              .toString()
                              .toLowerCase()
                              .contains(query.toLowerCase()) ||
                          element["customer"]["phone"]
                              .toString()
                              .toLowerCase()
                              .contains(query.toLowerCase()))
                      .toList()
                  : orderList;
              if (orderList.length > 0) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          height: size.height * 0.05,
                          padding: EdgeInsets.symmetric(vertical: 10.0),
                          alignment: Alignment.center,
                          color: kTangyYellow,
                          child: Text(
                            'Today: ' + today,
                            style:
                                TextStyle(fontSize: 18.0, color: Colors.black),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(12.0),
                          child: Text(
                            'Summary',
                            style: TextStyle(fontSize: 25.0),
                          ),
                        ),
                        Container(
                          child: SummaryTable(
                            toDeliverCount: orderList
                                .where((i) => i["status"] == 'ACTIVE')
                                .toList()
                                .length,
                            deliveredCount: orderList
                                .where((i) => i["status"] == 'DELIVERED')
                                .toList()
                                .length,
                            unDeliveredCount: orderList
                                .where((i) => i["status"] == 'UNDELIVERED')
                                .toList()
                                .length,
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: queryList.length,
                              itemBuilder: (context, index) {
                                return OrderCard(
                                  customerID: queryList[index]["customer"]
                                      ["id"],
                                  orderID: queryList[index]["id"],
                                  firstName: queryList[index]["customer"]
                                      ["firstName"],
                                  lastName: queryList[index]["customer"]
                                      ["lastName"],
                                  phone: queryList[index]["customer"]["phone"],
                                  address: queryList[index]["address"]["name"],
                                  products: queryList[index]["items"],
                                  isSub: queryList[index]["isSub"],
                                  status: queryList[index]["status"],
                                );
                              }),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return Center(child: Text('No order for you'));
            }
            return Text('Just a moment...');
          }),
    );
  }

  Future _getExecutiveID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    executiveID = prefs.getString('executiveID');
    firstName = prefs.getString('firstName');
    lastName = prefs.getString('lastName');
  }

  Future _logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.getKeys();
    prefs.clear();
    Get.offAll(LoginView());
  }

  @override
  void initState() {
    super.initState();
    _getExecutiveID();
  }
}
