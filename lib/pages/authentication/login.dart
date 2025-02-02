import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:frontend/constants.dart';
import 'package:frontend/controller/categories_controller.dart';
import 'package:frontend/controller/login_controller.dart';
import 'package:frontend/controller/mega_product_controller.dart';
import 'package:frontend/controller/signup_controller.dart';
import 'package:frontend/controller/theme_controller.dart';
import 'package:frontend/widgets/buttons.dart';
import 'package:frontend/widgets/custom_form.dart';
import 'package:frontend/widgets/layout.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:frontend/controller/UserController.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

class Login extends StatelessWidget {
  RxBool isErroccured = false.obs;
  final themeControllers = Get.find<ThemeControllers>();
  final loginController = Get.find<LoginController>();
  final sigunUpController = Get.find<SignUpController>();
  final userController =
      Get.find<UserController>(); // Instantiate UserController

  // final productController = Get.find<MegaProductController>();

  final tokenBox = GetStorage();
  TextEditingController phoneNumberControler = TextEditingController();
  TextEditingController passwordControler = TextEditingController();

  Widget build(BuildContext context) {
    Future.delayed(Duration(), () {
      sigunUpController.isSucessfulSignup.value = false;
    });

    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Obx(() => isErroccured.value
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(38.0, 0, 40, 18),
                        child: Container(
                            decoration: BoxDecoration(
                              color: Color.fromARGB(255, 255, 208, 205),
                              border: Border.all(color: Colors.red),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.warning,
                                    color: Colors.red,
                                  ),
                                  HorizontalSpace(10),
                                  Expanded(
                                    child: Text(
                                      style: TextStyle(
                                          letterSpacing: 2,
                                          wordSpacing: 2,
                                          color: Colors.red),
                                      'Incorrect phonenumber or password,please try again ',
                                      softWrap: true,
                                      maxLines: 2,
                                    ),
                                  )
                                ],
                              ),
                            )),
                      )
                    : Text('')),

                Obx(
                  () => sigunUpController.isSucessfulSignup.value
                      ? Padding(
                          padding: const EdgeInsets.fromLTRB(15.0, 0, 20, 0),
                          child: Container(
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: Colors.greenAccent[400],
                            ),
                            child: Row(
                              // mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                HorizontalSpace(5),
                                Icon(
                                  Icons.check_circle,
                                  color: whiteColor,
                                ),
                                HorizontalSpace(10),
                                Text(
                                  'Signed in successfully ',
                                  style: TextStyle(
                                      color: whiteColor, fontSize: 15),
                                ),
                              ],
                            ),
                          ),
                        )
                      : Text(''),
                ),

                // Center(
                //   child: Logo(),

                // ),
                Image(
                  image: AssetImage('assets/cropedlogo.png'),
                  width: 150,
                  height: 150,
                ),
                VerticalSpace(20),
                CustomForm(
                  editingController: phoneNumberControler,
                  onchanged: (value) {
                    print('Phone number ${value}');
                  },
                  hintText: ' Phone number',
                  isPassword: false,
                ),
                VerticalSpace(30),
                CustomForm(
                  // labelText: 'Password',
                  hintText: ' Password',
                  editingController: passwordControler,
                  isPassword: true,
                ),
                Row(
                  children: [
                    Expanded(child: Container()),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 5, 30, 0),
                      child: GestureDetector(
                        onTap: () {
                          Get.toNamed('/askphonenumber');
                        },
                        child: Text(
                          'Forgot password?',
                          style:
                              TextStyle(fontSize: 15, color: fotterTextColor),
                        ),
                      ),
                    )
                  ],
                ),

                VerticalSpace(40),

                GestureDetector(
                    onTap: () async {
                      // print('PhoneNumbers:${phoneNumberControler.text }');
                      // print('password:${passwordControler.text}');
                      String Phone_no = phoneNumberControler.text;
                      String password = passwordControler.text;
                      print('Phoneno:$Phone_no');
                      print('pass:$password');
                      loginController.isLoading.value = true;
                      // Get.toNamed('/productdesciption');

                      try {
                        print('login start');
                        loginController.isLoading.value = true;

                        final loginResponse = await loginController
                            .loginRequest(Phone_no, password);

                        print('login middle');

                        if (loginResponse.statusCode == 200) {
                          loginController.isLoading.value = false;

                          Get.toNamed('/mainpage');

                          print('ok response');

                          String accessToken = loginResponse.data['access'];
                          String refreshToken = loginResponse.data['refresh'];
                          print('response:$loginResponse');
                          int user_Id = loginResponse.data['user_id'];
                          userController
                              .checkIfUserIsSeller(user_Id.toString());

                          print(
                              'USERIDTYPE${loginResponse.data['user_id'].runtimeType}');
                          String userID = user_Id.toString();
                          int wallet_id = loginResponse.data['wallet_id'];

                          print(
                              'walletIdType${loginResponse.data['wallet_id'].runtimeType}');

                          tokenBox.write('accessToken', accessToken);
                          tokenBox.write('refreshToken', refreshToken);
                          tokenBox.write('walletId', wallet_id);

                          tokenBox.write('userID', userID);
                          String userId = tokenBox.read('userID').toString();
                          print('This is userId:$userId');
                          userController.setUserId(user_Id.toString());
                          // userController.userId.value = user_Id.toString();
                          print(
                              'useridfrom controller:${userController.userId}');

                          print('fromTokenBox:walletId${wallet_id}');
                          print('fromTokenBox:AcessToken  ${accessToken}');

                          tokenBox.write('userId', userId);
                          // int userIdFromStorage = tokenBox.read('userId');

                          print('fromTokenBox:walletId${wallet_id}');
                          Map<String, dynamic> decodedToken =
                              JwtDecoder.decode(accessToken);
                          print("Decodded ${decodedToken}");

                          print('fromTokenBox:AcessToken: ${accessToken}');
                          print('fromTokenBox:refreshToken${refreshToken}');

                          print('wallet-id :$wallet_id');

                          // Set user ID in UserController
                        } else {
                          //popup,show incorrect combination
                          // loginController.isLoading = false.obs;
                          loginController.isLoading.value = false;
                          isErroccured.value = true;
                          Future.delayed(Duration(seconds: 10), () {
                            isErroccured.value = false;
                          });
                          print('loginStatuscode:${loginResponse.statusCode}');
                        }
                      } catch (e) {
                        print(' Login exception ${e}');
                        loginController.isLoading.value = false;
                        isErroccured.value = true;
                        Future.delayed(Duration(seconds: 10), () {
                          isErroccured.value = false;
                        });
                        // Future.delayed(Duration(seconds: 10), () {
                        //   isErroccured.value = false;
                        // });
                      }
                    },
                    child: Obx(() =>
                        DefaultButton('SIGNIN'.tr, loginController.isLoading))),
                VerticalSpace(30),

                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 35.0),
                      child: HorizontalLine(height: 1, width: 120),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 10.0),
                      child: Text('OR'.tr),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: HorizontalLine(height: 1, width: 120),
                    ),
                  ],
                ),
                VerticalSpace(20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('NOACCOUNT'.tr),
                    HorizontalSpace(5),
                    GestureDetector(
                      onTap: () {
                        Get.toNamed('/signup');
                      },
                      child: Text(
                        'SIGNUP'.tr,
                        style: TextStyle(color: primaryColor),
                      ),
                    ),
                  ],
                ),
                VerticalSpace(150),
                // Container(
                //   height: 49,
                //   width: 342,
                //   decoration: BoxDecoration(
                //       border: Border.all(color: primaryColor),
                //       borderRadius: BorderRadius.circular(5)),
                //   child: Row(
                //     children: [
                //       Image.asset(
                //           width: 50, height: 50, 'assets/googlelogo.jpg'),
                //       HorizontalSpace(50),
                //       Center(
                //           child: Text(
                //         'Continue with Google',
                //         style: TextStyle(
                //             // color: primaryColor,
                //             // fontWeight: FontWeight.bold,
                //             fontSize: 15),
                //       )),
                //     ],
                //   ),
                // ),
                VerticalSpace(40),
                Padding(
                  padding: const EdgeInsets.all(38.0),
                  child: Center(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: <InlineSpan>[
                          TextSpan(
                              text: 'PRIVACY'.tr,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: fotterTextColor)),
                          TextSpan(
                              recognizer: TapGestureRecognizer()..onTap = () {},
                              text: 'TERM'.tr,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor)),
                          TextSpan(
                              text: 'AND'.tr,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: fotterTextColor)),
                          TextSpan(
                              text: 'POLICY'.tr,
                              recognizer: TapGestureRecognizer()..onTap = () {},
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor)),
                          TextSpan(
                              text: 'AGREED'.tr,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: fotterTextColor))
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ));
  }
}
