import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:milkton_executive/app/views/login/loginScreen.dart';
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
  String executiveID;
  String lastName;
  String firstName;
  List orderList = [];
  List deliveredOrderList = [];
  List unDeliveredOrderList = [];
  List toDeliverOrderList = [];
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Icon(Icons.notifications),
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
                    'Hey👋, $firstName $lastName',
                    style: TextStyle(color: kWhite, fontSize: 20.0),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.shop),
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
              print(orderList);
              return SingleChildScrollView(
                child: Center(
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
                            toDeliverCount: toDeliverOrderList.length,
                            deliveredCount: deliveredOrderList.length,
                            unDeliveredCount: unDeliveredOrderList.length,
                          ),
                        ),
                        Container(
                          child: ListView.builder(
                              itemCount: orderList.length,
                              itemBuilder: (context, index) {
                                return OrderCard(
                                  firstName: "Abhibhaw",
                                  lastName: "Asthana",
                                  phone: "7754949803",
                                  address: "ABC Apartment",
                                  products: [
                                    {"productID": "123", "quantity": "13"},
                                    {"productID": "456", "quantity": "238"}
                                  ],
                                );
                              }),
                        ),
                      ],
                    ),
                  ),
                ),
              );
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
