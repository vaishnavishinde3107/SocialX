import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socialx/features/auth/presentation/components/my_button.dart';
import 'package:socialx/features/auth/presentation/components/my_textfield.dart';
import 'package:socialx/features/auth/presentation/cubits/auth_cubit.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? togglePages;
  const RegisterPage({super.key, required this.togglePages});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  //name controller
  final nameController = TextEditingController();
  //email controller
  final emailController = TextEditingController();
  //password controller
  final passwordController = TextEditingController();
  //confirm-password controller
  final conPasswordController = TextEditingController();

//  void register(){

//     //get info
//     final String name = nameController.text;
//     final String email = emailController.text.trim();
//     final String password = passwordController.text;
//     final String conpass = conPasswordController.text;

//     //auth cubit
//     final authCubit = context.read<AuthCubit>();

//     //ensure the fields arent empty
//     if (name.isNotEmpty && email.isNotEmpty && password.isNotEmpty && conpass.isNotEmpty ) {
//       //ensure passwords match
//       if (password == conpass) {
//         authCubit.register(name, email, password);
//       }

//       //passwords don't match
//       else{
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Password do not match!"))
//         );
//       }
//     }

//     //if fields are empty
//     else{
//       ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("fill all the fields"))
//         );
//     }
//   }

void register() {
  // Get input values
  final String name = nameController.text.trim();
  final String email = emailController.text.trim();
  final String password = passwordController.text;
  final String conpass = conPasswordController.text;

  // Auth cubit
  final authCubit = context.read<AuthCubit>();

  // Validate email format
  final emailRegex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
  if (!emailRegex.hasMatch(email)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Invalid email format!")),
    );
    return;
  }

  // Ensure fields are not empty
  if (name.isNotEmpty && email.isNotEmpty && password.isNotEmpty && conpass.isNotEmpty) {
    // Ensure passwords match
    if (password == conpass) {
      authCubit.register(name, email, password);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match!")),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Fill all the fields")),
    );
  }
}


  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    conPasswordController.dispose();
    super.dispose();
  }
  
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lock_open_rounded,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                        
                  //welcome back message
                  Text("Welcome back, you've have been missed!",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 16,
                  ),
                  ),
                        
                  const SizedBox(height: 25,),
                  //name textfield
                  MyTextfield(
                    controller: nameController, 
                    hintText: "Enter Name", 
                    obscuretext: false),
                        
                  const SizedBox(height: 10,),
                        
                  //email textfield
                  MyTextfield(
                    controller: emailController, 
                    hintText: "Enter email", 
                    obscuretext: false),
                        
                  const SizedBox(height: 10,),
                  //password textfield
                  MyTextfield(
                    controller: passwordController, 
                    hintText: "Enter password", 
                    obscuretext: true),
              
                    const SizedBox(height: 10,),
                  //password textfield
                  MyTextfield(
                    controller: conPasswordController, 
                    hintText: "Confirm password", 
                    obscuretext: true),
              
                    const SizedBox(height: 25,),
                        
                  //register button
                  MyButton(
                    text: "Register", 
                    onTap: register,),
              
                    const SizedBox(height: 25,),
                  //register text
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already a member?",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      GestureDetector(
                        onTap: widget.togglePages,
                        child: Text(
                          " Login Now!",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.inversePrimary,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        )
        ),
    ); 
  }
}