const _meses = [
  'jan',
  'fev',
  'mar',
  'abr',
  'mai',
  'jun',
  'jul',
  'ago',
  'set',
  'out',
  'nov',
  'dez',
];

String _dois(int n) => n.toString().padLeft(2, '0');

String hora(DateTime d) => '${_dois(d.hour)}:${_dois(d.minute)}';

/// "14 nov, 09:30" — inclui o ano quando não é o ano corrente.
String dataHora(DateTime d, {DateTime? agora}) {
  final ref = agora ?? DateTime.now();
  final ano = d.year == ref.year ? '' : ' ${d.year}';
  return '${d.day} ${_meses[d.month - 1]}$ano, ${hora(d)}';
}

/// "agora", "há 5 min", "há 3 h", "ontem" ou a data.
String relativo(DateTime d, {DateTime? agora}) {
  final ref = agora ?? DateTime.now();
  final diff = ref.difference(d);
  if (diff.inMinutes < 1) return 'agora';
  if (diff.inMinutes < 60) return 'há ${diff.inMinutes} min';
  if (diff.inHours < 24) return 'há ${diff.inHours} h';
  if (diff.inDays == 1) return 'ontem';
  return dataHora(d, agora: ref);
}

String primeiroNome(String nome) {
  final partes = nome.trim().split(RegExp(r'\s+'));
  return partes.isEmpty ? nome : partes.first;
}

String iniciais(String nome) {
  final partes =
      nome.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (partes.isEmpty) return '?';
  if (partes.length == 1) return partes.first[0].toUpperCase();
  return (partes.first[0] + partes.last[0]).toUpperCase();
}
