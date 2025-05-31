class LoginValidator {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'E-MAIL É OBRIGATÓRIO';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!emailRegex.hasMatch(value)) {
      return 'E-MAIL INVÁLIDO';
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'SENHA É OBRIGATÓRIA';
    }

    // Verifica se tem pelo menos 6 caracteres
    if (value.length < 6) {
      return 'SENHA MUITO CURTA (mín. 6 caracteres)';
    }

    // Verifica se tem pelo menos 1 caractere maiúsculo
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'A SENHA DEVE CONTER PELO MENOS 1 LETRA MAIÚSCULA';
    }

    // Verifica se tem pelo menos 1 caractere especial
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
      return 'A SENHA DEVE CONTER PELO MENOS 1 CARACTERE ESPECIAL (@, #, %, etc.)';
    }

    return null;
  }
}
