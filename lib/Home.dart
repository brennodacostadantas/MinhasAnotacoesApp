import 'package:flutter/material.dart';
import 'package:minhas_anotacoes/helper/AnotacaoHelper.dart';
import 'package:minhas_anotacoes/model/Anotacao.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  TextEditingController _tituloController = TextEditingController();
  TextEditingController _descricaoController = TextEditingController();
  List<Anotacao> _anotacoes = [];
  var _db = AnotacaoHelper();

  _exibirTelaCadastro({Anotacao? anotacao}) {
    String textoSalvarAtualizar = "";
    if (anotacao == null) {
      _tituloController.text = "";
      _descricaoController.text = "";
      textoSalvarAtualizar = "Salvar";
    } else {
      _tituloController.text = anotacao.titulo!;
      _descricaoController.text = anotacao.descricao!;
      textoSalvarAtualizar = "Atualizar";
    }
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("${textoSalvarAtualizar} Anotação"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _tituloController,
                  autofocus: true,
                  decoration: InputDecoration(
                      labelText: "Título", hintText: "Digite o título"),
                ),
                TextField(
                  controller: _descricaoController,
                  decoration: InputDecoration(
                      labelText: "Descrição", hintText: "Digite a descrição"),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancelar")),
              ElevatedButton(
                  onPressed: () {
                    _salvarAtualizarAnotacao(anotacao: anotacao);
                    Navigator.pop(context);
                  },
                  child: Text(textoSalvarAtualizar)),
            ],
          );
        });
  }

  _salvarAtualizarAnotacao({Anotacao? anotacao}) async {
    String titulo = _tituloController.text;
    String descricao = _descricaoController.text;
    if (anotacao == null) {
      DateTime data = DateTime.now();
      Anotacao a = Anotacao(titulo, descricao, data.toString());
      int resultado = await _db.salvarAnotacao(a);
    } else {
      anotacao.titulo = titulo;
      anotacao.descricao = descricao;
      int resultado = await _db.atualizarAnotacao(anotacao);
    }
    _tituloController.clear();
    _descricaoController.clear();
    _recuperarAnotacoes();
  }

  _recuperarAnotacoes() async {
    List anotacoesRecuperadas = await _db.recuperarAnotacoes();
    List<Anotacao>? anotacoesTemporarias = [];
    for (var item in anotacoesRecuperadas) {
      Anotacao anotacao = Anotacao.fromMap(item);
      anotacoesTemporarias.add(anotacao);
    }
    setState(() {
      _anotacoes = anotacoesTemporarias!;
    });
    anotacoesTemporarias = null;
  }

  _removerAnotacao(int? id) async {
    await _db.removerAnotacao(id!);
    _recuperarAnotacoes();
  }

  _formatarData(String data) {
    initializeDateFormatting("pt_BR");
    //var formatador = DateFormat("d-M-y H:m:s");
    var formatador = DateFormat.yMd("pt_BR");
    DateTime dataConvertida = DateTime.parse(data);
    String dataFormatada = formatador.format(dataConvertida);
    return dataFormatada;
  }

  @override
  void initState() {
    super.initState();
    _recuperarAnotacoes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Minhas Anotações"),
        backgroundColor: Colors.lightBlue,
      ),
      body: Column(
        children: [
          Expanded(
              child: ListView.builder(
                  itemCount: _anotacoes.length,
                  itemBuilder: (context, idex) {
                    final anotacao = _anotacoes[idex];
                    return Card(
                      child: ListTile(
                        title: Text(anotacao.titulo.toString()),
                        subtitle: Text(
                            "${_formatarData(anotacao.data.toString())} - ${anotacao.descricao}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: () {
                                _exibirTelaCadastro(anotacao: anotacao);
                              },
                              child: Padding(
                                padding: EdgeInsets.only(right: 16),
                                child: Icon(
                                  Icons.edit,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                _removerAnotacao(anotacao.id);
                              },
                              child: Padding(
                                padding: EdgeInsets.only(right: 0),
                                child: Icon(
                                  Icons.remove_circle,
                                  color: Colors.red,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    );
                  }))
        ],
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          child: Icon(Icons.add),
          onPressed: () {
            _exibirTelaCadastro();
          }),
    );
  }
}
