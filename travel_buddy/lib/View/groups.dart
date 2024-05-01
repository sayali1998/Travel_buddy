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
              title: Text('Add New Group'),
              content: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      TextFormField(
                        controller: groupNameController,
                        decoration: InputDecoration(labelText: "Group name"),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a group name';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: emailController,
                        decoration: InputDecoration(labelText: "Add user emails (comma-separated)"),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter at least one email';
                          }
                          // Additional email validation logic can be implemented here
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: budgetController,
                        decoration: InputDecoration(labelText: "Budget"),
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
                      ListTile(
                        title: Text("Start Date: ${startDate != null ? DateFormat('yyyy-MM-dd').format(startDate!) : 'Not set'}"),
                        trailing: Icon(Icons.calendar_today),
                        onTap: () => _selectDate(context, setState, true),
                      ),
                      ListTile(
                        title: Text("End Date: ${endDate != null ? DateFormat('yyyy-MM-dd').format(endDate!) : 'Not set'}"),
                        trailing: Icon(Icons.calendar_today),
                        onTap: () => _selectDate(context, setState, false),
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () => Navigator.of(dialogContext).pop(),
                ),
                TextButton(
                  child: Text('Add'),
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
                          const SnackBar(content: Text("Group successfully added"))
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




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Groups'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: userGroup,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error loading groups: ${snapshot.error}"));
          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
            return  RefreshIndicator(
            onRefresh: fetchGroups,  
            child: ListView(
              children: snapshot.data!.map((item) {
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => GroupDetails(groupId: item['groupId']),
                        ),
                      );
                    },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 5,
                    margin: EdgeInsets.all(10),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: <Widget>[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              assetImages[Random().nextInt(assetImages.length)],
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  item['groupName'],
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "Group ID: ${item['groupId']}",
                                  style: TextStyle(
                                    fontSize: 14,
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
              }).toList(),
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

