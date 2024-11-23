import 'dart:convert';

import 'package:acesso_mapeado/models/accessibility_model.dart';
import 'package:acesso_mapeado/models/comment_model.dart';
import 'package:acesso_mapeado/shared/logger.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:acesso_mapeado/models/company_model.dart';
import 'package:acesso_mapeado/shared/design_system.dart';
import 'package:url_launcher/url_launcher.dart';
import 'info_tile.dart';
import 'custom_button.dart';
import 'comment_widget.dart';
import 'accessibility_section.dart';
import 'package:acesso_mapeado/pages/rate_page.dart';

class AccessibilitySheet extends StatefulWidget {
  final CompanyModel companyModel;

  const AccessibilitySheet({super.key, required this.companyModel});

  @override
  State<AccessibilitySheet> createState() => _AccessibilitySheetState();
}

class _AccessibilitySheetState extends State<AccessibilitySheet> {
  bool isMapExpanded = false;
  double mapHeight = 200;

  void toggleMapHeight() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(widget.companyModel.address),
          ),
          body: Stack(
            children: [
              GoogleMap(
                markers: <Marker>{
                  Marker(
                    markerId: MarkerId(widget.companyModel.name),
                    position: LatLng(
                      widget.companyModel.latitude ?? 0.0,
                      widget.companyModel.longitude ?? 0.0,
                    ),
                  ),
                },
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                    widget.companyModel.latitude ?? 0.0,
                    widget.companyModel.longitude ?? 0.0,
                  ),
                  zoom: 15,
                ),
                zoomGesturesEnabled: false,
                scrollGesturesEnabled: false,
                rotateGesturesEnabled: false,
                tiltGesturesEnabled: false,
                myLocationButtonEnabled: false,
                compassEnabled: false,
                zoomControlsEnabled: false,
              ),
              //button to open googlemaps on directions api
              Positioned(
                bottom: 16,
                right: 16,
                child: CustomButton(
                  label: 'Como chegar',
                  icon: Icons.directions,
                  onPressed: () async {
                    final Uri uri = Uri.parse(
                        'https://www.google.com/maps/dir/?api=1&destination=${widget.companyModel.latitude},${widget.companyModel.longitude}');
                    await launchUrl(uri);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7, // Tamanho inicial (70% da tela)
      minChildSize: 0.3, // Tamanho mínimo ao arrastar para baixo
      maxChildSize: 0.9, // Tamanho máximo ao arrastar para cima
      builder: (BuildContext context, ScrollController scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppSpacing.extraMedium),
            ),
          ),
          child: ListView(
            controller: scrollController,
            children: [
              // Indicador de arraste
              const SizedBox(
                height: 32.0,
                child: Center(
                  child: Divider(
                    color: AppColors.lightGray,
                    thickness: 2.0,
                    indent: 150.0,
                    endIndent: 150.0,
                  ),
                ),
              ),
              const SizedBox(height: 10.0),
              // Título e Rating
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    // Nome da Empresa
                    Expanded(
                      child: Text(
                        widget.companyModel.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                      ),
                    ),
                    // Rating
                    Column(
                      children: [
                        Text(
                          widget.companyModel.rating?.toStringAsFixed(1) ??
                              '0.0',
                          style: const TextStyle(
                            fontSize: AppSpacing.medium,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                          ),
                        ),
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              Icons.star,
                              color: index <
                                      (widget.companyModel.rating?.ceil() ?? 0)
                                  ? Colors.yellow
                                  : Colors.grey,
                              size: 20,
                            );
                          }),
                        ),
                        Text(
                          '(${widget.companyModel.ratings?.length ?? 0})',
                          style: const TextStyle(
                            fontSize: AppSpacing.small,
                            color: AppColors.lightGray,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10.0),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Center(
                        child: widget.companyModel.imageUrl != null &&
                                widget.companyModel.imageUrl!.isNotEmpty &&
                                widget.companyModel.imageUrl!.contains(',')
                            ? Image.memory(
                                base64Decode(
                                  widget.companyModel.imageUrl!.split(',')[1],
                                ),
                                height: 150,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Image.asset(
                                    'assets/images/img-company.png',
                                    height: 150,
                                    fit: BoxFit.cover,
                                  );
                                },
                              )
                            : Image.asset(
                                'assets/images/img-company.png',
                                height: 150,
                                fit: BoxFit.cover,
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              // ...
              const SizedBox(height: 10.0),
              // Botões de Ação
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 5.0, horizontal: 30.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CustomButton(
                      icon: Icons.star,
                      label: 'Avaliar',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RatePage(
                              company: widget.companyModel,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10.0),
              InkWell(
                onTap: () async {
                  Logger.logInfo('Abrindo Google Maps');
                  final Uri uri = Uri.parse(
                      'https://www.google.com/maps/search/?api=1&query=${widget.companyModel.address}');

                  Logger.logInfo('Abrindo Google Maps: $uri');
                  await launchUrl(uri);
                },
                child: InfoTile(
                  icon: Icons.location_on,
                  text: widget.companyModel.address,
                ),
              ),
              const SizedBox(height: 10.0),
              // Mapa da Localização
              Stack(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: mapHeight,
                    child: GoogleMap(
                      markers: <Marker>{
                        Marker(
                          markerId: MarkerId(widget.companyModel.name),
                          position: LatLng(widget.companyModel.latitude ?? 0.0,
                              widget.companyModel.longitude ?? 0.0),
                          infoWindow: InfoWindow(
                            title: widget.companyModel.name,
                            snippet: widget.companyModel.address,
                          ),
                        ),
                      },
                      initialCameraPosition: CameraPosition(
                        target: LatLng(widget.companyModel.latitude ?? 0.0,
                            widget.companyModel.longitude ?? 0.0),
                        zoom: 15,
                      ),
                      zoomGesturesEnabled: false,
                      scrollGesturesEnabled: false,
                      rotateGesturesEnabled: false,
                      tiltGesturesEnabled: false,
                      myLocationButtonEnabled: false,
                      compassEnabled: false,
                      zoomControlsEnabled: false,
                    ),
                  ),
                  SizedBox(
                    height: mapHeight,
                    width: MediaQuery.of(context).size.width,
                    child: GestureDetector(
                      onTap: toggleMapHeight,
                      child: const Text(''),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.extraMedium),
              // Telefone e Horário de Funcionamento
              InkWell(
                onTap: () async {
                  if (widget.companyModel.phoneNumber != null &&
                      widget.companyModel.phoneNumber!.isNotEmpty) {
                    final Uri uri =
                        Uri.parse('tel:${widget.companyModel.phoneNumber}');
                    await launchUrl(uri);
                  }
                },
                child: InfoTile(
                  icon: Icons.phone,
                  text: widget.companyModel.phoneNumber ??
                      'Telefone não disponível',
                ),
              ),
              // InfoTile(
              //   icon: Icons.access_time,
              //   text: widget.companyModel.workingHours ??
              //       'Horário de funcionamento não disponível',
              // ),
              const SizedBox(height: AppSpacing.extraMedium),
              // Seção de Acessibilidade
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  'Informações de Acessibilidade',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
              ),
              // Acessibilidade
              if (widget.companyModel.accessibilityData != null &&
                  widget.companyModel.accessibilityData!.accessibilityData
                      .isNotEmpty)
                ListView.builder(
                  shrinkWrap: true, // Ajusta o tamanho conforme o conteúdo
                  physics:
                      const NeverScrollableScrollPhysics(), // Desabilita o scroll interno
                  controller: scrollController,
                  itemCount: widget
                      .companyModel.accessibilityData!.accessibilityData.length,
                  itemBuilder: (context, index) {
                    String category = widget
                        .companyModel.accessibilityData!.accessibilityData.keys
                        .elementAt(index);
                    List<AccessibilityItem> items = widget.companyModel
                        .accessibilityData!.accessibilityData[category]!;

                    // Converte cada AccessibilityItem em Map<String, dynamic>
                    List<Map<String, dynamic>> itemsAsMap = items.map((item) {
                      return {
                        'tipo': item.type,
                        'status': item.status,
                      };
                    }).toList();

                    return AccessibilitySection(
                      category: category,
                      items: itemsAsMap, // Passa a lista convertida
                    );
                  },
                ),
              const SizedBox(height: AppSpacing.extraMedium),
              // Seção de Comentários
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  'Comentários',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
              ),
              if (widget.companyModel.commentsData != null &&
                  widget.companyModel.commentsData!.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  physics:
                      const NeverScrollableScrollPhysics(), // Desabilita o scroll interno
                  controller: scrollController,
                  itemCount: widget.companyModel.commentsData!.length,
                  itemBuilder: (context, index) {
                    CommentModel comment =
                        widget.companyModel.commentsData![index];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommentWidget(
                          userName: comment.userName,
                          userImage: comment.userImage,
                          text: comment.text,
                          date: comment.date,
                          rate: comment.rate,
                          photos: comment.photos,
                        ),
                      ],
                    );
                  },
                ),

              const SizedBox(height: AppSpacing.extraMedium),
              // Seção de Desempenho da Empresa
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  'Desempenho da Empresa',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
              ),
              //faça uma lista de 5 linhas onde cada linha será uma nota de 1 a 5, onde cada nota terá a quantidade de avaliacoes correspondentes
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: 5,
                itemBuilder: (context, index) {
                  final rating = 5 - index;
                  final ratings = widget.companyModel.ratings;
                  final count =
                      ratings?.where((r) => r.round() == rating).length ?? 0;
                  final total = ratings?.length ?? 0;
                  final value = total > 0 ? count / total : 0.0;

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 4.0),
                    child: Row(
                      children: [
                        Text('$rating ',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.black)),
                        const Text('★',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.yellow)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: LinearProgressIndicator(
                            value: value,
                            backgroundColor: AppColors.lightGray,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                AppColors.lightPurple),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('$count',
                            style: const TextStyle(color: AppColors.darkGray)),
                      ],
                    ),
                  );
                },
              ),

              // Seção Sobre a Empresa
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // CNPJ
                    RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text: 'CNPJ: ',
                            style: TextStyle(
                              fontSize: AppSpacing.medium,
                              color: AppColors.lightPurple,
                            ),
                          ),
                          TextSpan(
                            text: widget.companyModel.cnpj,
                            style: const TextStyle(
                              fontSize: AppSpacing.medium,
                              color: AppColors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    // Data de Cadastro
                    RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Data de Cadastro: ',
                            style: TextStyle(
                              fontSize: AppSpacing.medium,
                              color: AppColors.lightPurple,
                            ),
                          ),
                          TextSpan(
                            text: widget.companyModel.registrationDate != null
                                ? formatDate(
                                    DateTime.parse(
                                        widget.companyModel.registrationDate!),
                                    [dd, '/', mm, '/', yyyy])
                                : 'Data de cadastro não disponível',
                            style: const TextStyle(
                              fontSize: AppSpacing.medium,
                              color: AppColors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    // Descrição Sobre a Empresa
                    RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(
                            text: 'Descrição: ',
                            style: TextStyle(
                              fontSize: AppSpacing.medium,
                              color: AppColors.lightPurple,
                            ),
                          ),
                          TextSpan(
                            text: widget.companyModel.about ??
                                'Descrição não disponível',
                            style: const TextStyle(
                              fontSize: AppSpacing.medium,
                              color: AppColors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.extraMedium),
            ],
          ),
        );
      },
    );
  }
}
