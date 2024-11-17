import 'package:acesso_mapeado/shared/design_system.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';

class CommentWidget extends StatelessWidget {
  final String? userName;
  final String? userImage;
  final String? text;
  final String? date;
  final double? rate;

  const CommentWidget({
    super.key,
    this.userName,
    this.userImage,
    this.text,
    this.date,
    this.rate,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundImage: AssetImage(
                    userImage ?? 'assets/images/placeholder-user.png'),
                radius: 20.0,
              ),
              const SizedBox(width: 10.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          userName ?? 'Nome do usuário não disponível',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.extraSmall),
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              Icons.star,
                              color: index < (rate ?? 0)
                                  ? Colors.yellow
                                  : Colors.grey,
                              size: 20,
                            );
                          }),
                        ),
                      ],
                    ),
                    ...[
                      if (text != null && text!.isNotEmpty)
                        Text(text ?? 'Comentário não disponível'),
                      const SizedBox(height: 4.0),
                    ],
                    Text(
                      date != null
                          ? formatDate(
                              DateTime.parse(date!),
                              [HH, ':', nn, ' ', dd, '/', mm, '/', yyyy],
                            )
                          : 'Data não disponível',
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
  }
}
