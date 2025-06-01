import 'package:resultx/resultx.dart';

class User {
  final String name;
  final int age;

  User(this.name, this.age);

  @override
  String toString() {
    return 'User {name: $name, age: $age}';
  }
}

class UserWithActiveStatus extends User {
  final bool isActive;
  UserWithActiveStatus(super.name, super.age, this.isActive);

  @override
  String toString() {
    return 'UserWithActiveStatus {name: $name, age: $age, isActive: $isActive}';
  }
}

// Future<Result<User, String>> getUserResult([bool throwError = false])
FtrResult<User, String> getUser([bool success = true]) async {
  await Future.delayed(Duration(milliseconds: 10));
  if (!success) {
    return Error('Error getting user');
  }
  final user = User('Dart User', 30);
  return Success(user);
}

FtrResult<bool, String> isUserActive(User user) async {
  await Future.delayed(Duration(milliseconds: 10));
  return Success(user.name.length > 5); // dummy
}

FtrResult<int, String> getStatusCode([bool success = true]) {
  return getUser(success).mapSuccess((_) => 1);
}

Future showReslveDemo() async {
  // try to get the status code
  // when its error, the code will be -1
  final statusCode = await getStatusCode().resolve(onError: (_) => -1).data;
  print('showReslveDemo :: Status code: $statusCode');

  // you can also make it nullable and return null if error
  final statusCode2 =
      await getStatusCode(false).nullable().resolve(onError: (_) => null).data;
  print('showReslveDemo :: Status code2: $statusCode2');
}

Future showWhenDemo() async {
  await getUser().when(
    success: (user) => print('showWhenDemo :: Success Occured: $user'),
    error: (e) => print('showWhenDemo :: Error Occured: $e'),
  );

  // you can also return a value from when clause if needed
  final res = await getUser(false).when(
    success: (user) => 'showWhenDemo :: Success Occured: $user',
    error: (e) => 'showWhenDemo :: Error Occured: $e',
  );
  print(res);
}

Future showGetOrThrowDemo() async {
  try {
    final user = await getUser().getOrThrow();
    print('showGetOrThrowDemo :: Success Occured: $user');
  } catch (e) {
    print('showGetOrThrowDemo :: Error Occured: $e');
  }
}

Future showExecuteDemo() async {
  // use .execute() to when you dont care about the result
  await getUser().execute();
  await getUser(false).execute();
  print('showExecuteDemo :: Executed');
}

// chain as many callbacks as you want
// no need to call await on each callback
// results handle the futures internally
Future showCallBackDemo() async {
  final user = await getUser()
      .onSuccess((user) => print('showCallBackDemo :: Success Occured: $user'))
      .onError((e) => print('showCallBackDemo :: Error Occured: $e'))
      .onSuccess(
        (user) => print('showCallBackDemo 2ndCallBack :: User : $user'),
      )
      .nullable()
      .resolve(onError: (_) => null)
      .data;
  print('showCallBackDemo :: User Unchanged: $user');
}

// you can chain different mapping methods to get the result
// maps: success -> mapSuccess : change the value to another type, mapOnSuccess: change the result to another result
// maps: error -> mapError: change the error to another type, mapOnError: change the result to another result
Future showMappingDemo() async {
  final user = await getUser()
      .mapOnSuccess(
        (user) => isUserActive(user).mapSuccess(
          (isActive) => UserWithActiveStatus(user.name, user.age, isActive),
        ),
      )
      .nullable()
      .resolve(onError: (_) => null)
      .data;
  print('showMappingDemo :: User Unchanged: $user');
}

// call the flat method to get the data and error as a dart record
// you can use this to get the data and error as a dart record
Future showFlatRecordsDemo() async {
  final (user, error) = await getUser().flat();
  print('showFlatRecordsDemo :: User: $user, Error: $error');
}

main() async {
  await showReslveDemo();

  print('\n');
  await showWhenDemo();

  print('\n');
  await showGetOrThrowDemo();

  print('\n');
  await showExecuteDemo();

  print('\n');
  await showCallBackDemo();

  print('\n');
  await showMappingDemo();

  print('\n');
  await showFlatRecordsDemo();

  print('\n');
}
