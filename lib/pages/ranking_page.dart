import 'package:acesso_mapeado/pages/home_page.dart';
import 'package:acesso_mapeado/pages/profile_user_page.dart';
import 'package:acesso_mapeado/pages/rate_page.dart';
import 'package:acesso_mapeado/shared/app_colors.dart';
import 'package:acesso_mapeado/shared/app_navbar.dart';
import 'package:flutter/material.dart';

class RankingPage extends StatefulWidget {
  const RankingPage({super.key});

  @override
  State<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends State<RankingPage> {
  int _selectedIndex = 2;

  void _navigate(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
        break;
      case 1:
        // Navegar para o bate-papo
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const RankingPage()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ProfileUserPage()),
        );
        break;
    }
  }

// Dados sobre ranking das empresas (Itens que vão ficar no firebase)
  final Map<String, List<Map<String, dynamic>>> _companyRakingData = {
    'company': [
      {
        'name': 'Empresa 1',
        'rating': 4,
        'imageUrl': 'assets/images/img-company.png'
      },
      {
        'name': 'Empresa 2',
        'rating': 4,
        'imageUrl': 'assets/images/img-company.png'
      },
      {
        'name': 'Empresa 3',
        'rating': 3,
        'imageUrl': 'assets/images/img-company.png'
      },
      {
        'name': 'Empresa 4',
        'rating': 2,
        'imageUrl': 'assets/images/img-company.png'
      },
    ]
  };

  // Dados da empresa
  final Map<String, dynamic> _companyData = {
    "name": "Empresa Exemplo",
    "imageUrl": 'assets/images/img-company.png',
    "address": "Rua Exemplo, 123",
    "phoneNumber": "(11) 1234-5678",
    "workingHours": "Seg-Sex, 8h às 18h",
    "rating": 4.5,
    "accessibilityData": {
      "Acessibilidade Física": [
        {"tipo": "Rampas", "status": true},
        {"tipo": "Elevadores", "status": true},
        {"tipo": "Portas Largas", "status": true},
        {"tipo": "Banheiros Adaptados", "status": false},
        {"tipo": "Pisos e Superfícies Anti-derrapantes", "status": true},
        {"tipo": "Estacionamento Reservado", "status": true}
      ],
      "Acessibilidade Comunicacional": [
        {"tipo": "Sinalização com Braille e Pictogramas", "status": true},
        {"tipo": "Informações Visuais Claras e Contrastantes", "status": true},
        {"tipo": "Dispositivos Auditivos", "status": false},
        {
          "tipo": "Documentos e Materiais em Formatos Acessíveis",
          "status": true
        }
      ],
      "Acessibilidade Sensorial": [
        {"tipo": "Iluminação Adequada", "status": true},
        {"tipo": "Redução de Ruídos", "status": true}
      ],
      "Acessibilidade Atitudinal": [
        {"tipo": "Treinamento de Funcionários", "status": true},
        {"tipo": "Políticas Inclusivas", "status": true}
      ],
    },
    "performanceData": {
      "numberOfComments": "150",
      "responseRate": "98%",
      "pendingConversations": "2",
      "numberOfReviews": "130",
      "averageRating": "9.2",
      "returningCustomersPercentage": "92,5%",
      "resolvedConversationsRate": "97%",
      "averageResponseTime": "14 horas",
    },
    "commentsData": [
      {
        "title": "Excelente acessibilidade!",
        "userImage": 'assets/images/placeholder-user.png',
        "userName": "Carlos Souza",
        "text": "O local é muito bem adaptado para cadeirantes.",
        "date": "02/09/2024",
      },
      {
        "title": "Muito bom",
        "userImage": 'assets/images/placeholder-user.png',
        "userName": "Ana Oliveira",
        "text": "Gostei muito do atendimento e das instalações.",
        "date": "30/08/2024",
      },
    ],
    "cnpj": "12345678000190",
    "registrationDate": "01 de Fev de 2024",
    "about":
        "Empresa de exemplo especializada em soluções acessíveis para todos. Comprometida com a inclusão e acessibilidade.",
  };

  void _showAccessibilitySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5, // Tamanho inicial
          minChildSize: 0.3, // Tamanho mínimo ao arrastar para baixo
          maxChildSize: 0.9, // Tamanho máximo ao arrastar para cima
          builder: (BuildContext context, ScrollController scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20.0),
                ),
              ),
              child: ListView(
                controller: scrollController,
                children: [
                  const SizedBox(
                    height: 40.0,
                    width: 50.0,
                    child: Divider(
                      color: AppColors.lightGray,
                      thickness: 2.0,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _companyData["name"] ?? 'Nome da Empresa',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppColors.black,
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            Text(
                              _companyData["rating"]?.toString() ?? '0.0',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.black,
                              ),
                            ),
                            Row(
                              children: List.generate(5, (index) {
                                return Icon(
                                  Icons.star,
                                  color: index < (_companyData["rating"] ?? 0.0)
                                      ? Colors.yellow
                                      : Colors.grey,
                                  size: 20,
                                );
                              }),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Center(
                      child: Image(
                        image: AssetImage(_companyData["imageUrl"] ??
                            'assets/images/img-company.png'),
                        height: 150,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 5.0, horizontal: 30.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.lightPurple),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: TextButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RatePage(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.star,
                                color: AppColors.lightPurple),
                            label: const Text(
                              'Avaliar',
                              style: TextStyle(color: AppColors.lightPurple),
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsets.only(left: 10),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.lightPurple),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: TextButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.message_outlined,
                                color: AppColors.lightPurple),
                            label: const Text(
                              'Chat',
                              style: TextStyle(color: AppColors.lightPurple),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on,
                            color: AppColors.lightPurple),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: Text(
                            _companyData["address"] ??
                                'Endereço não disponível',
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.darkGray,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [
                        const Icon(Icons.phone, color: AppColors.lightPurple),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: Text(
                            _companyData["phoneNumber"] ??
                                'Telefone não disponível',
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.darkGray,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.access_time,
                          color: AppColors.lightPurple,
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: Text(
                            _companyData["workingHours"] ??
                                'Horário de funcionamento não disponível',
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.darkGray,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      'Informações de Acessibilidade',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                  ..._companyData["accessibilityData"].entries.map((entry) {
                    String category = entry.key;
                    List<Map<String, dynamic>> items =
                        List<Map<String, dynamic>>.from(entry.value);
                    IconData icon;

                    switch (category) {
                      case "Acessibilidade Física":
                        icon = Icons.accessible;
                        break;
                      case "Acessibilidade Comunicacional":
                        icon = Icons.spatial_audio_off;
                        break;
                      case "Acessibilidade Sensorial":
                        icon = Icons.favorite;
                        break;
                      case "Acessibilidade Atitudinal":
                        icon = Icons.person;
                        break;
                      default:
                        icon = Icons.accessibility_new;
                    }

                    return ExpansionTile(
                      title: Row(
                        children: [
                          Icon(icon, color: AppColors.lightPurple),
                          const SizedBox(width: 8.0),
                          Text(
                            category,
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppColors.black,
                            ),
                          ),
                        ],
                      ),
                      children: items.map((item) {
                        return ListTile(
                          title: Text(
                            item["tipo"] ?? 'Tipo não disponível',
                            style: const TextStyle(color: AppColors.darkGray),
                          ),
                          trailing: item["status"] ?? false
                              ? const Icon(Icons.check, color: Colors.green)
                              : const Icon(Icons.close, color: Colors.red),
                        );
                      }).toList(),
                    );
                  }).toList(),
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Comentários',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                  ..._companyData["commentsData"].map((comment) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            comment["title"] ?? 'Título não disponível',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.black,
                            ),
                          ),
                          const SizedBox(height: 8.0),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                backgroundImage: AssetImage(
                                    comment["userImage"] ??
                                        'assets/images/placeholder-user.png'),
                                radius: 20.0,
                              ),
                              const SizedBox(width: 10.0),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      comment["userName"] ??
                                          'Nome do usuário não disponível',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 4.0),
                                    Text(
                                      comment["text"] ??
                                          'Comentário não disponível',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.darkGray,
                                      ),
                                    ),
                                    const SizedBox(height: 4.0),
                                    Text(
                                      comment["date"] ?? 'Data não disponível',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.lightGray,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Divider(color: AppColors.lightGray),
                        ],
                      ),
                    );
                  }).toList(),
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Desempenho da Empresa',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                  ...[
                    {
                      "icon": Icons.comment,
                      "description":
                          "Esta empresa recebeu ${_companyData['performanceData']['numberOfComments'] ?? '0'} comentários.",
                    },
                    {
                      "icon": Icons.check_circle,
                      "description":
                          "Respondeu ${_companyData['performanceData']['responseRate'] ?? '0%'} das conversas recebidas.",
                    },
                    {
                      "icon": Icons.hourglass_empty,
                      "description":
                          "Há ${_companyData['performanceData']['pendingConversations'] ?? '0'} conversas aguardando resposta.",
                    },
                    {
                      "icon": Icons.star_border,
                      "description":
                          "Há ${_companyData['performanceData']['numberOfReviews'] ?? '0'} comentários avaliados, e a nota média dos consumidores é ${_companyData['performanceData']['averageRating'] ?? '0.0'}.",
                    },
                    {
                      "icon": Icons.thumb_up,
                      "description":
                          "Dos que avaliaram, ${_companyData['performanceData']['returningCustomersPercentage'] ?? '0%'} voltariam a fazer negócio.",
                    },
                    {
                      "icon": Icons.check_circle,
                      "description":
                          "A empresa resolveu ${_companyData['performanceData']['resolvedConversationsRate'] ?? '0%'} das conversas recebidas.",
                    },
                    {
                      "icon": Icons.access_time,
                      "description":
                          "O tempo médio de respostas é ${_companyData['performanceData']['averageResponseTime'] ?? '0'}.",
                    },
                  ].map((item) {
                    return ListTile(
                      leading: Icon(item["icon"] as IconData,
                          color: AppColors.lightPurple),
                      title: Text(
                        item["description"] as String,
                        style: const TextStyle(
                          fontSize: 16,
                          color: AppColors.black,
                        ),
                      ),
                    );
                  }),
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Sobre',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              const TextSpan(
                                text: 'CNPJ: ',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.lightPurple,
                                ),
                              ),
                              TextSpan(
                                text: _companyData["cnpj"] ??
                                    'CNPJ não disponível',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: AppColors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        RichText(
                          text: TextSpan(
                            children: [
                              const TextSpan(
                                text: 'Data de Cadastro: ',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: AppColors.lightPurple,
                                ),
                              ),
                              TextSpan(
                                text: _companyData["registrationDate"] ??
                                    'Data de cadastro não disponível',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: AppColors.black,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          _companyData["about"] ??
                              'Informações sobre a empresa não disponíveis.',
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppColors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: const Text('Ranking'),
        backgroundColor: AppColors.white,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            boxShadow: [
              BoxShadow(
                  color: AppColors.darkGray.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 2))
            ],
          ),
        ),
        leading: IconButton(
          icon: Image.asset('assets/icons/arrow-left.png'),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          },
        ),
      ),
       body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 30),
            const Text(
              'Quer saber quais empresas com melhores índices?',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.darkGray, fontSize: 18),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: ListView.builder(
                itemCount: _companyRakingData['company']?.length ?? 0,
                itemBuilder: (context, index) {
                  final company = _companyRakingData['company']![index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: AssetImage(company['imageUrl'] ?? ''),
                      radius: 29,
                    ),
                    title: Text(company['name'] ?? ''),
                    subtitle: Row(
                      children: List.generate(5, (starIndex) {
                        return Icon(
                          Icons.star,
                          color: starIndex < (company['rating'] ?? 0)
                              ? Colors.yellow
                              : Colors.grey,
                          size: 20,
                        );
                      }),
                    ),
                    trailing: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.lightPurple),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _companyData["name"] = company['name'];
                            _companyData["rating"] = company['rating'];
                            _companyData["imageUrl"] = company['imageUrl'];
                          });
                          _showAccessibilitySheet();
                        },
                        label: const Text(
                          'Saiba mais',
                          style: TextStyle(color: AppColors.lightPurple),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar:
          AppNavbar(selectedIndex: _selectedIndex, onItemTapped: _navigate),
    );
  }
}