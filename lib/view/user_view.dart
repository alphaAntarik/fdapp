import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../viewmodel/user_viewmodel.dart';

class UserView extends StatefulWidget {
  UserView({super.key});

  @override
  State<UserView> createState() => _UserViewState();
}

class _UserViewState extends State<UserView> {
  final userVM = Get.put(UserViewModel());
  final userViewModel = Get.find<UserViewModel>();
  @override
  Widget build(BuildContext context) {
    // print(userViewModel.users[0].name);
    print(userVM.users);
    print("userViewModel.users[index].name");
    return Scaffold(
      appBar: AppBar(
        title: const Text('Users'),
      ),
      body: GetBuilder<UserViewModel>(
        builder: (userViewModel) {
          if (userViewModel.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            itemCount: userViewModel.users.length,
            itemBuilder: (BuildContext context, int index) {
              return Card(
                elevation: 4, // Add some elevation for a shadow effect
                margin: EdgeInsets.symmetric(
                    vertical: 8, horizontal: 16), // Adjust margin
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(12), // Round corners of the card
                ),
                child: ListTile(
                  contentPadding:
                      EdgeInsets.all(16), // Padding inside the ListTile
                  title: Text(
                    userViewModel.users[index].name,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue, // Customize text color
                    ),
                  ),
                  subtitle: Text(
                    userViewModel.users[index].surname,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey, // Customize text color
                    ),
                  ),
                  trailing: Container(
                    child: userViewModel.isLoading1 &&
                            userViewModel.uid == userViewModel.users[index].id
                        ? CircularProgressIndicator()
                        : IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              userViewModel
                                  .deleteUser(userViewModel.users[index].id);
                            },
                          ),
                  ),
                ),
              );
            },
          );

          // ListView.builder(
          //   itemCount: userViewModel.users.length,
          //   itemBuilder: (context, index) {

          //     return
          //     ListTile(
          //       title: Text(userViewModel.users[index].name),
          //       subtitle: Text(userViewModel.users[index].surname),
          //       trailing: IconButton(
          //         icon: const Icon(
          //           Icons.delete,
          //           color: Colors.red,
          //         ),
          //         onPressed: () {
          //           userViewModel.deleteUser(userViewModel.users[index].id);
          //         },
          //       ),
          //     );
          //   },
          // );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('New User'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: userViewModel.nameController,
                      decoration: const InputDecoration(
                        hintText: 'Enter name',
                      ),
                    ),
                    TextField(
                      controller: userViewModel.surnameController,
                      decoration: const InputDecoration(
                        hintText: 'Enter surname',
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      userViewModel.addUser(
                        userViewModel.nameController.text,
                        userViewModel.surnameController.text,
                      );
                      Navigator.pop(context);
                    },
                    child: const Text('Add'),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
