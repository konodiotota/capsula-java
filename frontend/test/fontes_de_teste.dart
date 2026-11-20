import 'package:flutter/services.dart';

/// Carrega as fontes do app para que os testes meçam o texto real em vez da
/// fonte substituta, que é muito mais larga.
Future<void> carregarFontesDoApp() async {
  Future<void> familia(String nome, List<String> arquivos) async {
    final loader = FontLoader(nome);
    for (final a in arquivos) {
      loader.addFont(rootBundle.load('assets/fonts/$a'));
    }
    await loader.load();
  }

  await familia('Pixel', ['Jersey10.ttf']);
  await familia('Mono', ['JetBrainsMono.ttf']);
}
