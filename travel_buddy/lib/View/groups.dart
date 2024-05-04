import 'package:flutter/material.dart';
import 'package:travel_buddy/View/group_details.dart';
import 'package:travel_buddy/ViewModel/firebase_functions.dart';
import 'package:intl/intl.dart';
import 'dart:math';

class GroupScreen extends StatefulWidget {
  final String userId;

  GroupScreen({Key? key, required this.userId}) : super(key: key);

  @override
  GroupScreenPage createState() => GroupScreenPage();
}

class GroupScreenPage extends State<GroupScreen> {
  Future<List<Map<String, dynamic>>>? userGroup;
  TextEditingController groupNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController budgetController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final List<String> assetImages = [
    'assets/group1.png',
    'assets/group2.png',
    'assets/group3.png',
    'assets/group4.png',
    'assets/group5.png',
  ];

  @override
  void initState() {
    super.initState();
    userGroup = fetchUserGroups(widget.userId);
  }

  void _showAddGroupDialog() {
  showDialog(
  context: context,
  builder: (dialogContext) {
    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        return AlertDialog(
          title: Text('Add New Group', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  TextFormField(
                    controller: groupNameController,
                    decoration: InputDecoration(
                      labelText: "Group name",
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).primaryColorLight, width: 1.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a group name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: "Add user emails (comma-separated)",
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).primaryColorLight, width: 1.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter at least one email';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    controller: budgetController,
                    decoration: InputDecoration(
                      labelText: "Budget",
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).primaryColorLight, width: 1.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2.0),
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a budget';
                      }
                      if (double.tryParse(value) == null) {
                        return 'Please enter a valid number';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 10),
                  ListTile(
                    title: Text("Start Date: ${startDate != null ? DateFormat('yyyy-MM-dd').format(startDate!) : 'Not set'}"),
                    trailing: Icon(Icons.calendar_today, color: Theme.of(context).primaryColor),
                    onTap: () => _selectDate(context, setState, true),
                  ),
                  ListTile(
                    title: Text("End Date: ${endDate != null ? DateFormat('yyyy-MM-dd').format(endDate!) : 'Not set'}"),
                    trailing: Icon(Icons.calendar_today, color: Theme.of(context).primaryColor),
                    onTap: () => _selectDate(context, setState, false),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Colors.red)),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: Text('Add', style: TextStyle(color: Colors.green)),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  try {
                    String groupId = await addGroup(
                      groupName: groupNameController.text,
                      budget: budgetController.text,
                      startDate: startDate,
                      endDate: endDate,
                    );

                    List<String> userEmails = emailController.text.split(',').map((e) => e.trim()).toList();
                    addUsersToGroup(groupId, userEmails, groupNameController.text, widget.userId);

                    Navigator.of(dialogContext).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Group successfully added"))
                    );
                    groupNameController.clear();
                    emailController.clear();
                    budgetController.clear();
                    startDate = null;
                    endDate = null;
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Failed to add group: $e"))
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  },
);

  
  }


  Future<void> _selectDate(BuildContext context, StateSetter setState, bool isStart) async {
    final DateTime now = DateTime.now();
    final DateTime initialDate = isStart
        ? startDate?.isBefore(now) ?? true ? now : startDate!
        : endDate?.isBefore(startDate ?? now) ?? true ? startDate ?? now : endDate!;
    final DateTime firstDate = isStart ? now : startDate ?? now;

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      setState(() {
        if (isStart) {
          startDate = pickedDate;
        } else {
          endDate = pickedDate;
        }
      });
    }
  }


  Future<void> fetchGroups() async {
    setState(() {
      userGroup = fetchUserGroups(widget.userId);
    });
    await userGroup;  
  }

Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Groups', style: TextStyle(color: Colors.white)), 
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: userGroup,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error loading groups: ${snapshot.error}"));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return RefreshIndicator(
              onRefresh: fetchGroups,
              child: ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  var item = snapshot.data![index];
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GroupDetails(groupId: item['groupId'], userId: widget.userId),
                        ),
                      );
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: <Widget>[
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                assetImages[Random().nextInt(assetImages.length)],
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    item['groupName'],
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    "Group ID: ${item['groupId']}",
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          } else {
            return Center(child: Text("No Groups"));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddGroupDialog,
        tooltip: 'Add Group',
        child: Icon(Icons.add), 
      ),
    );
  }
}

