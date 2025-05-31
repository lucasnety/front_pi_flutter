import 'package:flutter/material.dart';
import 'home_page.dart';
import 'home_adm.dart';
import '../services/auth_service.dart';

const Color kPrimaryColor = Color(0xFFFFD72C);

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey =
      GlobalKey<FormState>(); // GlobalKey para validar o formulário
  bool _isLoading = false;
  final _authService = AuthService();

  // Função de login
  void _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      bool success = await _authService.login(
        _emailController.text,
        _passwordController.text,
      );

      // Simulando o processo de login com um delay
      // await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Navegar para a HomePage/HomeADMPage após login bem-sucedido
        if (success) {
          String? admin = await _authService.getAdmin();

          if (admin == "1") {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeAdmPage()),
            );
          } else {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          }

          // mensagem se login falho
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('falha no login.')));
        }
      }
    }
  }

  // Função de validação do e-mail
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'E-MAIL É OBRIGATÓRIO';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'E-MAIL INVÁLIDO';
    }

    return null;
  }

  // Função de validação da senha
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'SENHA É OBRIGATÓRIA';
    }

    if (value.length < 6) {
      return 'SENHA MUITO INCORRETA)';
    }

    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'A SENHA DEVE CONTER PELO MENOS 1 LETRA MAIÚSCULA';
    }

    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'A SENHA DEVE CONTER PELO MENOS 1 CARACTERE ESPECIAL (@, #, %, etc.)';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/img_fundo.png', fit: BoxFit.cover),
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 60),
            child: Column(
              children: [
                const SizedBox(height: 30),
                Image.asset('assets/images/logo_semfundo.png', height: 200),
                const SizedBox(height: 40),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(217, 255, 255, 255),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: 80,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromRGBO(0, 0, 0, 0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Image.asset(
                            'assets/images/icon_user.png',
                            height: 60,
                            color: const Color.fromARGB(255, 85, 85, 85),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Formulário de login com validação
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: _emailController,
                              decoration: InputDecoration(
                                labelText: 'E-mail',
                                prefixIcon: Icon(
                                  Icons.email,
                                  color: kPrimaryColor,
                                ),
                                border: const OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.emailAddress,
                              validator: _validateEmail,
                            ),
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _passwordController,
                              decoration: InputDecoration(
                                labelText: 'Senha',
                                prefixIcon: Icon(
                                  Icons.lock,
                                  color: kPrimaryColor,
                                ),
                                border: const OutlineInputBorder(),
                              ),
                              obscureText: true,
                              validator: _validatePassword,
                            ),
                            const SizedBox(height: 12),
                            Center(
                              child: TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/recuperacao');
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.grey[600],
                                ),
                                child: const Text('Esqueci minha senha'),
                              ),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child:
                                  _isLoading
                                      ? const Center(
                                        child: CircularProgressIndicator(),
                                      )
                                      : ElevatedButton(
                                        onPressed: _login,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: kPrimaryColor,
                                          foregroundColor: Colors.black,
                                        ),
                                        child: const Text('Fazer Login'),
                                      ),
                            ),
                            const SizedBox(height: 12),
                            Center(
                              child: TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/cadastro');
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.grey[700],
                                ),
                                child: const Text('Criar conta'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
