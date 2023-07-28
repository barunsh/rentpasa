import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  final String? names;
  final String? email;
  final int? phone;
  final String? id;

  ProfilePage({
    this.id,
    this.names,
    this.email,
    this.phone,
  });
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool IsReadonly = true;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Center(
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 300,
                  color: Colors.white,
                ),
                Positioned(
                  height: 250,
                  width: 300,
                  top: 50,
                  left: 60,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        image: AssetImage("assets/modern.jpg"),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 40,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 700,
                    child: ListView(
                      children: [
                        ListTile(
                          title: Text(
                            'Name',
                            style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            "${widget.names}",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          trailing: Icon(Icons.person),
                        ),
                        Divider(),
                        ListTile(
                          title: Text(
                            'Email',
                            style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${widget.email}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          trailing: Icon(Icons.email),
                        ),
                        Divider(),
                        ListTile(
                          title: Text(
                            'Contact',
                            style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '+977-${widget.phone}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          trailing: Icon(Icons.phone),
                        ),
                        Divider(),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
