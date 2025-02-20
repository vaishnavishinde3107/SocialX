/*
LOGIN PAGE

On this page, an existing user can login with their:
-email
-password

--------------------------------------------------------

Once the user successfully logs in they will be redirected to home page.

If user doesnt have an account yet, they can go to register page from here to 
create one.
 */

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialx/features/auth/presentation/components/my_button.dart';
import 'package:socialx/features/auth/presentation/components/my_textfield.dart';
import 'package:socialx/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:socialx/features/auth/presentation/cubits/auth_state.dart';
import 'package:socialx/features/post/presentation/pages/home_page.dart';

class LoginPage extends StatefulWidget {
  final void Function()? togglePages;
  const LoginPage({super.key, required this.togglePages});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //email controller
  final emailController = TextEditingController();
  //password controller
  final passwordController = TextEditingController();

  //login button pressed
  void login() {
    //prepare email and password
    final String email = emailController.text;
    final String password = passwordController.text;

    //auth cubit
    final authCubit = context.read<AuthCubit>();
    //ensure email and password fields are not empty
    if (email.isNotEmpty && password.isNotEmpty) {
      //login
      authCubit.login(email, password);
      //dismiss keyboard
      FocusScope.of(context).unfocus();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter both email and password"),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                duration: const Duration(seconds: 2),
              ),
            );
          }
        },
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_open_rounded,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),

                  //welcome back message
                  Text(
                    "Welcome back, you've have been missed!",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 25),

                  //email textfield
                  MyTextfield(
                    controller: emailController,
                    hintText: "Enter email",
                    obscuretext: false,
                  ),

                  const SizedBox(height: 10),
                  //password textfield
                  MyTextfield(
                    controller: passwordController,
                    hintText: "Enter password",
                    obscuretext: true,
                  ),

                  const SizedBox(height: 25),

                  //login button
                  MyButton(
                    text: "Login",
                    onTap: login,
                  ),

                  const SizedBox(height: 25),

                  //register text
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Not a member?",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      GestureDetector(
                        onTap: widget.togglePages,
                        child: Text(
                          " Register Now!",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.inversePrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

}