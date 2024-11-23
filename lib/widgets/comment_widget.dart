import 'dart:convert';

import 'package:acesso_mapeado/shared/design_system.dart';
import 'package:acesso_mapeado/widgets/image_zoom_widget.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';

class CommentWidget extends StatelessWidget {
  final String? userName;
  final String? userImage;
  final String? text;
  final String? date;
  final double? rate;
  final List<String>? photos;

  const CommentWidget({
    super.key,
    this.userName,
    this.userImage,
    this.text,
    this.date,
    this.rate,
    this.photos,
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
                backgroundImage: userImage != null && userImage!.isNotEmpty
                    ? MemoryImage(
                        base64Decode(
                            userImage!), // Converte a string base64 para bytes
                      )
                    : const AssetImage('assets/images/placeholder-user.png')
                        as ImageProvider,
                radius: 25.0,
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
                            fontSize: AppTypography.large,
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
                        Text(
                          text ?? 'Comentário não disponível',
                          style: const TextStyle(fontSize: AppTypography.large),
                        ),
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
          if (photos != null && photos!.isNotEmpty)
            SizedBox(
              height: 150,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: AppSpacing.small,
                  mainAxisSpacing: AppSpacing.small,
                ),
                itemCount: photos!.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ImageZoomWidget(
                              photos: photos!, initialIndex: index),
                        ),
                      );
                    },
                    child: AspectRatio(
                      aspectRatio: 1.0,
                      child: Image.memory(
                        base64Decode(photos![index].split(',')[1]),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            ),
          const Divider(color: AppColors.lightGray),
        ],
      ),
    );
  }
}
