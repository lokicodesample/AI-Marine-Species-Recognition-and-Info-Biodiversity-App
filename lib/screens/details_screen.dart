import 'dart:io';
import 'package:flutter/material.dart';
import '../models/creature_model.dart';
import '../utils/constants.dart';

class DetailsScreen extends StatelessWidget {
  final Creature creature;
  final File? selectedImage;

  const DetailsScreen({
    super.key,
    required this.creature,
    this.selectedImage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(context),
          _buildContentSection(),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      floating: false,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: _buildHeroImage(),
        title: Text(
          creature.name,
          style: AppTextStyles.button.copyWith(
            fontSize: 18,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
            ],
          ),
        ),
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        collapseMode: CollapseMode.parallax,
      ),
      backgroundColor: AppColors.primary,
      leading: _buildBackButton(context),
    );
  }

  Widget _buildHeroImage() {
    return Hero(
      tag: creature.name,
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.black12, Colors.black26],
          ),
        ),
        child: selectedImage != null
            ? Image.file(
          selectedImage!,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildFallbackImage(),
        )
            : Image.asset(
          creature.imagePath,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildFallbackImage(),
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return IconButton(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            shape: BoxShape.circle,
            boxShadow: [
        BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 6,
        offset: const Offset(0, 2),
        )],
      ),
      child: const Icon(Icons.arrow_back, color: AppColors.primary),
    ),
    onPressed: () => Navigator.pop(context),
    );
  }

  SliverToBoxAdapter _buildContentSection() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusChip(),
            const SizedBox(height: 25),
            _buildSection(
              title: 'Physical Characteristics',
              icon: Icons.straighten,
              children: [
                _buildInfoRow('Average Height:', creature.averageHeight),
                _buildInfoRow('Average Weight:', creature.averageWeight),
              ],
            ),
            _buildSection(
              title: 'Habitat Information',
              icon: Icons.location_pin,
              children: [
                _buildInfoRow('Primary Habitat:', creature.habitat),
                _buildInfoRow('Conservation:', creature.conservationStatus),
              ],
            ),
            _buildSection(
              title: 'Diet & Safety',
              icon: Icons.restaurant,
              children: [
                _buildInfoRow('Edibility Status:', creature.edibility),
                _buildInfoRow('Primary Diet:', creature.diet),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    return Chip(
      backgroundColor: _getStatusColor().withOpacity(0.1),
      label: Text(
        creature.conservationStatus,
        style: TextStyle(
          color: _getStatusColor(),
          fontWeight: FontWeight.w600,
        ),
      ),
      avatar: Icon(
        Icons.eco,
        color: _getStatusColor(),
        size: 18,
      ),
    );
  }

  Color _getStatusColor() {
    switch (creature.conservationStatus.toLowerCase()) {
      case 'endangered':
        return Colors.red;
      case 'vulnerable':
        return Colors.orange;
      case 'least concern':
        return Colors.green;
      default:
        return AppColors.primary;
    }
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 22),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: AppTextStyles.title.copyWith(fontSize: 18),
                ),
              ],
            ),
            const Divider(height: 25, thickness: 0.8),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: AppTextStyles.body.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.secondary.withOpacity(0.8),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.body.copyWith(
                color: AppColors.secondary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackImage() {
    return Container(
      color: Colors.grey[100],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image, size: 50, color: Colors.grey[400]),
            const SizedBox(height: 10),
            Text(
              'Image not available',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      ),
    );
  }
}