// CLASSE DO MODELO DE DADOS DO SERVIÇO
// ESSA ESTRUTURA PODE SER ADAPTADA PARA RECEBER UM JSON DE UMA API FUTURAMENTE
class Servico {
  final String nome;
  final double valor_unitario;

  Servico({required this.nome, required this.valor_unitario});

  // MÉTODO DE FÁBRICA PARA CONVERTER UM JSON EM UM OBJETO
  // FUTURAMENTE UTILIZADO COM O RETORNO DA API
  factory Servico.fromJson(Map<String, dynamic> json) {
    return Servico(
      nome: json['nome'],
      valor_unitario: double.parse(json['valor_unitario']),
    );
  }
}
