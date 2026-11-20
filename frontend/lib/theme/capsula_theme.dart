import 'package:material_ui/material_ui.dart';

import '../domain/models.dart';

/// Um conjunto completo de cores. A Capsula tem duas: escura, o console de
/// atendimento, e clara, a mesma interface sobre papel branco.
class Paleta {
  const Paleta({
    required this.escura,
    required this.fundo,
    required this.lateral,
    required this.painel,
    required this.painelAlto,
    required this.borda,
    required this.bordaForte,
    required this.texto,
    required this.creme,
    required this.suave,
    required this.apagado,
    required this.brasa,
    required this.sobreBrasa,
    required this.visto,
    required this.alerta,
    required this.amarelo,
    required this.mapaFundo,
    required this.mapaRua,
    required this.mapaRuaFina,
    required this.mapaAvenida,
  });

  final bool escura;
  final Color fundo,
      lateral,
      painel,
      painelAlto,
      borda,
      bordaForte,
      texto,
      creme,
      suave,
      apagado,
      brasa,
      sobreBrasa,
      visto,
      alerta,
      amarelo,
      mapaFundo,
      mapaRua,
      mapaRuaFina,
      mapaAvenida;

  static const escuro = Paleta(
    escura: true,
    fundo: Color(0xFF0C0C0E),
    lateral: Color(0xFF09090A),
    painel: Color(0xFF161618),
    painelAlto: Color(0xFF1F1F23),
    borda: Color(0xFF2C2C31),
    bordaForte: Color(0xFF43434A),
    texto: Color(0xFFEDE9E0),
    creme: Color(0xFFF2E2C0),
    suave: Color(0xFFA5A39D),
    apagado: Color(0xFF85848A),
    brasa: Color(0xFFFF6B4A),
    sobreBrasa: Color(0xFF1A0E0A),
    visto: Color(0xFF35D07F),
    alerta: Color(0xFFFF4D4F),
    amarelo: Color(0xFFF5C542),
    mapaFundo: Color(0xFF101317),
    mapaRua: Color(0xFF1C2127),
    mapaRuaFina: Color(0xFF181C21),
    mapaAvenida: Color(0xFF272D34),
  );

  /// Tons escurecidos onde a cor vira texto sobre branco, para manter o
  /// contraste.
  static const claro = Paleta(
    escura: false,
    fundo: Color(0xFFF5F4F0),
    lateral: Color(0xFFECEAE5),
    painel: Color(0xFFFFFFFF),
    painelAlto: Color(0xFFF0EEE9),
    borda: Color(0xFFDCD9D2),
    bordaForte: Color(0xFF96928A),
    texto: Color(0xFF1A1A1E),
    creme: Color(0xFF8A5410),
    suave: Color(0xFF54545C),
    apagado: Color(0xFF6B6B73),
    brasa: Color(0xFFCC3F1F),
    sobreBrasa: Color(0xFFFFFFFF),
    visto: Color(0xFF12804A),
    alerta: Color(0xFFD1242F),
    amarelo: Color(0xFF946400),
    mapaFundo: Color(0xFFE6E3DC),
    mapaRua: Color(0xFFFAF9F6),
    mapaRuaFina: Color(0xFFEFEDE8),
    mapaAvenida: Color(0xFFFFFFFF),
  );
}

/// Cores em uso. Troque a paleta com [usar] e reconstrua a árvore de widgets
/// (a `CapsulaApp` faz as duas coisas).
abstract final class Cores {
  static Paleta _p = Paleta.escuro;

  static void usar(Paleta p) => _p = p;

  static bool get escura => _p.escura;

  static Color get fundo => _p.fundo;
  static Color get lateral => _p.lateral;
  static Color get painel => _p.painel;
  static Color get painelAlto => _p.painelAlto;
  static Color get borda => _p.borda;
  static Color get bordaForte => _p.bordaForte;

  static Color get texto => _p.texto;
  static Color get creme => _p.creme;
  static Color get suave => _p.suave;
  static Color get apagado => _p.apagado;

  static Color get brasa => _p.brasa;
  static Color get sobreBrasa => _p.sobreBrasa;
  static Color get visto => _p.visto;
  static Color get alerta => _p.alerta;
  static Color get amarelo => _p.amarelo;

  static Color get mapaFundo => _p.mapaFundo;
  static Color get mapaRua => _p.mapaRua;
  static Color get mapaRuaFina => _p.mapaRuaFina;
  static Color get mapaAvenida => _p.mapaAvenida;

  static Color prioridade(Prioridade p) => switch (p) {
        Prioridade.urgente => alerta,
        Prioridade.alta => brasa,
        Prioridade.media => amarelo,
        Prioridade.baixa => visto,
      };
}

abstract final class Fontes {
  static const pixel = 'Pixel';
  static const corpo = 'Mono';
}

abstract final class Estilos {
  static List<FontVariation> _peso(double w) => [FontVariation('wght', w)];

  /// Títulos em fonte pixel (Jersey 10). Ela tem x-height baixo, então o
  /// tamanho é ampliado para casar com o corpo em mono.
  static TextStyle titulo({double tamanho = 22, Color? cor}) => TextStyle(
        fontFamily: Fontes.pixel,
        fontSize: tamanho * 1.25,
        fontWeight: FontWeight.w400,
        height: 1.0,
        letterSpacing: .3,
        color: cor ?? Cores.texto,
      );

  /// Título grande com extrusão em degraus, como nas telas de referência.
  static TextStyle tituloExtrudado({
    double tamanho = 56,
    Color? cor,
    Color? sombra,
  }) {
    final face = cor ?? (Cores.escura ? const Color(0xFFFF7A5C) : Cores.brasa);
    final extrusao = sombra ??
        (Cores.escura ? const Color(0xFF9E3520) : const Color(0xFF7A2410));
    return titulo(tamanho: tamanho, cor: face).copyWith(
      height: .86,
      shadows: [
        for (var i = 1; i <= 4; i++)
          Shadow(color: extrusao, offset: Offset(i.toDouble(), i.toDouble())),
      ],
    );
  }

  /// Valores de dados: números, horários, ids.
  static TextStyle mono({
    double tamanho = 14,
    Color? cor,
    FontWeight peso = FontWeight.w500,
  }) =>
      corpo(tamanho: tamanho, cor: cor, peso: peso);

  static TextStyle corpo({
    double tamanho = 15,
    Color? cor,
    FontWeight peso = FontWeight.w400,
  }) =>
      TextStyle(
        fontFamily: Fontes.corpo,
        fontSize: tamanho,
        fontWeight: peso,
        fontVariations: _peso(peso.value.toDouble()),
        height: 1.5,
        color: cor ?? Cores.texto,
      );
}

/// Raio das janelas, campos e botões.
const double raioFolha = 5;

ThemeData construirTema() {
  final esquema = ColorScheme(
    brightness: Cores.escura ? Brightness.dark : Brightness.light,
    primary: Cores.brasa,
    onPrimary: Cores.sobreBrasa,
    secondary: Cores.creme,
    onSecondary: Cores.sobreBrasa,
    error: Cores.alerta,
    onError: Cores.sobreBrasa,
    surface: Cores.painel,
    onSurface: Cores.texto,
    outline: Cores.borda,
    outlineVariant: Cores.borda,
  );

  final base = ThemeData(
    useMaterial3: true,
    colorScheme: esquema,
    fontFamily: Fontes.corpo,
  );

  OutlineInputBorder borda(Color cor, [double largura = 1.2]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(raioFolha),
        borderSide: BorderSide(color: cor, width: largura),
      );

  final botao =
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(raioFolha));

  return base.copyWith(
    scaffoldBackgroundColor: Cores.fundo,
    canvasColor: Cores.fundo,
    textTheme: base.textTheme.copyWith(
      displaySmall: Estilos.titulo(tamanho: 52),
      headlineMedium: Estilos.titulo(tamanho: 32),
      headlineSmall: Estilos.titulo(tamanho: 26),
      titleLarge: Estilos.titulo(tamanho: 22),
      titleMedium: Estilos.corpo(tamanho: 16, peso: FontWeight.w700),
      bodyLarge: Estilos.corpo(tamanho: 16),
      bodyMedium: Estilos.corpo(tamanho: 14, cor: Cores.suave),
      labelLarge: Estilos.corpo(tamanho: 15, peso: FontWeight.w700),
      labelMedium: Estilos.corpo(tamanho: 13, cor: Cores.suave),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Cores.fundo,
      foregroundColor: Cores.texto,
      elevation: 0,
      scrolledUnderElevation: 0,
      titleTextStyle: Estilos.titulo(tamanho: 22),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Cores.painel,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      hintStyle: Estilos.corpo(tamanho: 15, cor: Cores.apagado),
      labelStyle: Estilos.corpo(tamanho: 15, cor: Cores.suave),
      floatingLabelStyle: Estilos.corpo(tamanho: 15, cor: Cores.brasa),
      helperStyle: Estilos.corpo(tamanho: 13, cor: Cores.suave),
      errorStyle: Estilos.corpo(tamanho: 13, cor: Cores.alerta),
      prefixIconColor: Cores.suave,
      suffixIconColor: Cores.suave,
      border: borda(Cores.bordaForte),
      enabledBorder: borda(Cores.borda),
      focusedBorder: borda(Cores.brasa, 2),
      errorBorder: borda(Cores.alerta),
      focusedErrorBorder: borda(Cores.alerta, 2),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: Cores.brasa,
        foregroundColor: Cores.sobreBrasa,
        disabledBackgroundColor: Cores.painelAlto,
        disabledForegroundColor: Cores.apagado,
        minimumSize: const Size(0, 50),
        padding: const EdgeInsets.symmetric(horizontal: 22),
        shape: botao,
        textStyle: Estilos.corpo(tamanho: 15, peso: FontWeight.w800),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Cores.texto,
        disabledForegroundColor: Cores.apagado,
        minimumSize: const Size(0, 50),
        padding: const EdgeInsets.symmetric(horizontal: 22),
        side: BorderSide(color: Cores.bordaForte, width: 1.4),
        shape: botao,
        textStyle: Estilos.corpo(tamanho: 15, peso: FontWeight.w700),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: Cores.brasa,
        minimumSize: const Size(0, 44),
        shape: botao,
        textStyle: Estilos.corpo(tamanho: 15, peso: FontWeight.w700),
      ),
    ),
    iconButtonTheme: IconButtonThemeData(
      style: IconButton.styleFrom(foregroundColor: Cores.suave),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: Cores.brasa,
      foregroundColor: Cores.sobreBrasa,
      elevation: 0,
      focusElevation: 0,
      hoverElevation: 0,
      highlightElevation: 0,
      extendedTextStyle: Estilos.corpo(tamanho: 15, peso: FontWeight.w800),
      shape: botao,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: Cores.lateral,
      surfaceTintColor: Colors.transparent,
      indicatorColor: Cores.painelAlto,
      indicatorShape: botao,
      height: 68,
      iconTheme: WidgetStateProperty.resolveWith(
        (s) => IconThemeData(
          color: s.contains(WidgetState.selected) ? Cores.brasa : Cores.suave,
        ),
      ),
      labelTextStyle: WidgetStateProperty.resolveWith(
        (s) => Estilos.corpo(
          tamanho: 12,
          peso: FontWeight.w700,
          cor: s.contains(WidgetState.selected) ? Cores.texto : Cores.suave,
        ),
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: Cores.painel,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(raioFolha),
        side: BorderSide(color: Cores.bordaForte),
      ),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: Cores.painelAlto,
      surfaceTintColor: Colors.transparent,
      textStyle: Estilos.corpo(tamanho: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(raioFolha),
        side: BorderSide(color: Cores.bordaForte),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: Cores.texto,
      contentTextStyle:
          Estilos.corpo(tamanho: 14, cor: Cores.fundo, peso: FontWeight.w600),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(raioFolha)),
    ),
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: Cores.painelAlto,
        borderRadius: BorderRadius.circular(raioFolha),
        border: Border.all(color: Cores.bordaForte),
      ),
      textStyle: Estilos.corpo(tamanho: 13),
    ),
    dividerTheme: DividerThemeData(color: Cores.borda, space: 1, thickness: 1),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: Cores.brasa),
    focusColor: Cores.brasa.withValues(alpha: .22),
  );
}
