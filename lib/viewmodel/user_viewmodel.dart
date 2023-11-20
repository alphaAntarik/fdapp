import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';

import 'package:web3dart/web3dart.dart';
import 'package:http/http.dart' as http;

import '../model/user.dart';

class UserViewModel extends GetxController {
  TextEditingController nameController = TextEditingController();
  TextEditingController surnameController = TextEditingController();
  List<User> users = [];

  bool isLoading = true;
  bool isLoading1 = false;
  int uid = 0;

  final String _privatekey =
      '0x6b42cd1cb3b18c724e01d6b8c63d21e92d7a952477dd218a82131ce44655577d';

  Web3Client web3client = Web3Client("http://localhost:7545", http.Client());

  @override
  void onReady() async {
    await getABI();
    await getCredentials();
    await getDeployedContract();
    //await fetchUsers();
    super.onReady();
  }

  late ContractAbi _abiCode;
  late EthereumAddress _contractAddress;

  Future<void> getABI() async {
    String abiFile =
        await rootBundle.loadString('build/contracts/UsersContract.json');
    var jsonABI = jsonDecode(abiFile);
    _abiCode =
        ContractAbi.fromJson(jsonEncode(jsonABI['abi']), 'UsersContract');
    _contractAddress =
        EthereumAddress.fromHex(jsonABI["networks"]["5777"]["address"]);
  }

  late EthPrivateKey _creds;
  Future<void> getCredentials() async {
    _creds = EthPrivateKey.fromHex(_privatekey);
  }

  late DeployedContract _deployedContract;
  late ContractFunction _createUser;
  late ContractFunction _deleteUser;
  late ContractFunction _users;
  late ContractFunction _userCount;
  late ContractFunction _getAllUsers;

  Future<void> getDeployedContract() async {
    _deployedContract = DeployedContract(_abiCode, _contractAddress);
    _createUser = _deployedContract.function('createUser');
    _deleteUser = _deployedContract.function('deleteUser');
    _users = _deployedContract.function('users');
    _userCount = _deployedContract.function('userCount');
    _getAllUsers = _deployedContract.function('getAllUsers');
    await fetchUsers();
  }

  // Future<void> fetchUsers() async {
  //   var data = await web3client.call(
  //     contract: _deployedContract,
  //     function: _userCount,
  //     params: [],
  //   );

  //   int totalTaskLen = data[0].toInt();
  //   users.clear();
  //   for (var i = 0; i < totalTaskLen; i++) {
  //     var temp = await web3client.call(
  //         contract: _deployedContract,
  //         function: _users,
  //         params: [BigInt.from(i)]);

  //     if (temp[1] != "") {
  //       users.add(
  //         User(
  //           id: (temp[0] as BigInt).toInt(),
  //           name: temp[1],
  //           surname: temp[2],
  //         ),
  //       );
  //     }
  //     print(users[0].name);
  //   }

  //   isLoading = false;
  //   update();
  //   //Text(users[0].name);
  // }

  // Future<void> fetchUsers() async {
  //   var data = await web3client.call(
  //     contract: _deployedContract,
  //     function: _userCount,
  //     params: [],
  //   );

  //   int totalTaskLen = data[0].toInt();
  //   users.clear();

  //   if (totalTaskLen > 0) {
  //     for (var i = 0; i < totalTaskLen; i++) {
  //       var temp = await web3client.call(
  //         contract: _deployedContract,
  //         function: _users,
  //         params: [BigInt.from(i)],
  //       );

  //       if (temp[1] != "") {
  //         users.add(
  //           User(
  //             id: (temp[0] as BigInt).toInt(),
  //             name: temp[1],
  //             surname: temp[2],
  //           ),
  //         );
  //       }
  //     }
  //   }

  //   isLoading = false;
  //   update();
  // }
  Future<void> fetchUsers() async {
    var data = await web3client.call(
      contract: _deployedContract,
      function: _getAllUsers,
      params: [],
    );
    users.clear();

    print(data[0].length);
    if (data[0].length != 0) {
      for (List<dynamic> i in data[0]) {
        users.add(User(
          id: (i[0] as BigInt).toInt(),
          name: i[1],
          surname: i[2],
        ));
      }
    }
    // for (List<List<dynamic>> userDataList in data) {
    //   for (List<dynamic> userData in userDataList) {
    //     int id = userData[0] as int;
    //     String name = userData[1] as String;
    //     String surname = userData[2] as String;

    //     User user = User(
    //       id: id,
    //       name: name,
    //       surname: surname,
    //     );

    //     users.add(user);
    //   }
    // }

    // int totalTaskLen = data[0].toInt();
    // users.clear();

    // if (totalTaskLen > 0) {
    //   for (var i = 0; i < totalTaskLen; i++) {
    //     var temp = await web3client.call(
    //       contract: _deployedContract,
    //       function: _users,
    //       params: [BigInt.from(i)],
    //     );

    //     if (temp[1] != "") {
    //       users.add(
    //         User(
    //           id: (temp[0] as BigInt).toInt(),
    //           name: temp[1],
    //           surname: temp[2],
    //         ),
    //       );
    //     }
    //   }
    // }

    isLoading = false;
    update();
  }

  Future<void> addUser(String name, String surname) async {
    isLoading = true;

    update();
    final response = await web3client.sendTransaction(
      _creds,
      chainId: 1337,
      Transaction.callContract(
        contract: _deployedContract,
        function: _createUser,
        parameters: [name, surname],
      ),
    );
    print(response);
    nameController.clear();
    surnameController.clear();
    // isLoading = true;
    // isLoading = false;
    // update();
    await fetchUsers();
  }

  // Future<void> deleteUser(int id) async {
  //   isLoading = true;
  //   update();
  //   await web3client.sendTransaction(
  //     _creds,
  //     chainId: 1337,
  //     Transaction.callContract(
  //       contract: _deployedContract,
  //       function: _deleteUser,
  //       parameters: [BigInt.from(id)],
  //     ),
  //   );
  //   // isLoading = true;
  //   await fetchUsers();
  // }
  Future<void> deleteUser(int id) async {
    // isLoading = true;
    isLoading1 = true;
    uid = id;
    update();
    await web3client.sendTransaction(
      _creds,
      chainId: 1337,
      Transaction.callContract(
        contract: _deployedContract,
        function: _deleteUser,
        parameters: [BigInt.from(id)],
      ),
    );
    // isLoading = true;
    isLoading1 = false;
    uid = 0;
    // update();
    fetchUsers();
  }

  // Future<void> deleteUser(int id) async {
  //   isLoading = true;
  //   update();

  //   try {
  //     print('Deleting user with ID: $id');
  //     await web3client.sendTransaction(
  //       _creds,
  //       chainId: 1337,
  //       Transaction.callContract(
  //         contract: _deployedContract,
  //         function: _deleteUser,
  //         parameters: [BigInt.from(id)],
  //       ),
  //     );

  //     // Update the local users list only after a successful deletion
  //     await fetchUsers();

  //     print('User deleted successfully');
  //   } catch (e) {
  //     print('Error deleting user: $e');
  //     // Handle errors, update UI or show a message to the user
  //   }
  // }
}
