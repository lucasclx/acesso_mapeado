import 'package:acesso_mapeado/controllers/company_controller.dart';
import 'package:acesso_mapeado/models/company_model.dart';
import 'package:acesso_mapeado/pages/home_page.dart';
import 'package:acesso_mapeado/shared/design_system.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RatePage extends StatefulWidget {
  const RatePage({super.key, required this.company});

  final CompanyModel company;

  @override
  State<RatePage> createState() => _RatePageState();
}

class _RatePageState extends State<RatePage> {
 final TextEditingController _comment = TextEditingController();
 final CompanyController _company = CompanyController();
  double _rating = 0;

  // Função para adicionar comentário e avaliação
  addCommentAndRating() async {
    bool result =
        await _company.addUserComment(widget.company.uuid, _comment.text);
    bool ratingResult =
        await _company.addCompanyUserRating(widget.company.uuid, _rating);

    if (result && ratingResult) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Avaliação enviada com sucesso!')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao enviar avaliação.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
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
        title: Row(
          children: [
            Text(
              'Avaliar ${widget.company.name}',
              style:
                  const TextStyle(color: AppColors.lightPurple, fontSize: 18),
            ),
          ],
        ),
      ),
      backgroundColor: AppColors.white,
      body: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(10),
            child: const Row(
              children: [
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Nome do Usuário',
                      style:
                          TextStyle(fontSize: 18, color: AppColors.lightPurple),
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'Sua postagem será pública.',
                          style: TextStyle(
                              fontSize: 14, color: AppColors.darkGray),
                        ),
                        Icon(Icons.warning_rounded,
                            color: AppColors.lightPurple),
                      ],
                    )
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: RatingBar.builder(
              initialRating: _rating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemBuilder: (context, _) => const Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                setState(() {
                  _rating = rating; // Atualizar o rating
                });
              },
            ),
          ),
          const SizedBox(height: 16.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              maxLines: 4,
              controller: _comment,
              decoration: InputDecoration(
                hintText: 'Conte como foi sua experiência neste lugar',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add_a_photo, color: AppColors.lightPurple),
              label: const Text(
                'Adicionar foto',
                style: TextStyle(color: AppColors.lightPurple),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                addCommentAndRating();
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                backgroundColor: AppColors.lightPurple,
              ),
              child: const Text(
                'Enviar avaliação',
                style: TextStyle(color: AppColors.white, fontSize: 18),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
