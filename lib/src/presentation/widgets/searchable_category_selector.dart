import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:heroes_app/src/domain/models/business_category.dart';

class SearchableCategorySelector extends StatefulWidget {
  final List<BusinessCategory> categories;
  final String? selectedCategoryId;
  final Function(String?) onCategorySelected;
  final String allCategoriesText;

  const SearchableCategorySelector({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
    required this.allCategoriesText,
  });

  @override
  State<SearchableCategorySelector> createState() =>
      _SearchableCategorySelectorState();
}

class _SearchableCategorySelectorState
    extends State<SearchableCategorySelector> {
  final TextEditingController _searchController = TextEditingController();
  List<BusinessCategory> _filteredCategories = [];

  @override
  void initState() {
    super.initState();
    _filteredCategories = widget.categories;
    _searchController.addListener(_filterCategories);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCategories() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredCategories = widget.categories;
      } else {
        _filteredCategories = widget.categories
            .where((category) => category.name.toLowerCase().contains(query))
            .toList();
      }
    });
  }

  String _getSelectedCategoryName() {
    if (widget.selectedCategoryId == null || widget.selectedCategoryId!.isEmpty) {
      return widget.allCategoriesText;
    }
    final category = widget.categories.firstWhere(
      (cat) => cat.id == widget.selectedCategoryId,
      orElse: () => BusinessCategory(
        id: '',
        name: widget.allCategoriesText,
        imageUrl: '',
      ),
    );
    return category.name;
  }

  void _showCategorySelector() {
    // Reset search when opening
    _searchController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (modalContext) => StatefulBuilder(
        builder: (context, setModalState) {
          // Update filter with modal state
          void localFilterCategories() {
            final query = _searchController.text.toLowerCase();
            setModalState(() {
              if (query.isEmpty) {
                _filteredCategories = widget.categories;
              } else {
                _filteredCategories = widget.categories
                    .where((category) => category.name.toLowerCase().contains(query))
                    .toList();
              }
            });
          }

          return DraggableScrollableSheet(
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.9,
            expand: false,
            builder: (context, scrollController) {
              return Column(
                children: [
                  // Handle bar
                  Container(
                    margin: const EdgeInsets.only(top: 8, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Title
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Text(
                      'Seleccionar Categoría',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  // Search field
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Buscar categoría...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  localFilterCategories();
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                      ),
                      autofocus: false,
                      onChanged: (_) => localFilterCategories(),
                    ),
                  ),
                  const Divider(height: 1),
                  // Categories list
                  Expanded(
                    child: _filteredCategories.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text(
                                'No se encontraron categorías',
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                            ),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            itemCount: _filteredCategories.length + 1,
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                // "All categories" option
                                final isSelected = widget.selectedCategoryId == null ||
                                    widget.selectedCategoryId!.isEmpty;
                                return ListTile(
                                  leading: SvgPicture.asset(
                                    "assets/icon/allCategories.svg",
                                    width: 32,
                                    height: 32,
                                  ),
                                  title: Text(
                                    widget.allCategoriesText,
                                    style: TextStyle(
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                    ),
                                  ),
                                  trailing: isSelected
                                      ? Icon(
                                          Icons.check_circle,
                                          color: Theme.of(context).colorScheme.primary,
                                        )
                                      : null,
                                  selected: isSelected,
                                  onTap: () {
                                    widget.onCategorySelected('');
                                    Navigator.pop(context);
                                  },
                                );
                              }

                              final category = _filteredCategories[index - 1];
                              final isSelected = widget.selectedCategoryId == category.id;

                              return ListTile(
                                leading: SvgPicture.network(
                                  category.imageUrl,
                                  width: 32,
                                  height: 32,
                                ),
                                title: Text(
                                  category.name,
                                  style: TextStyle(
                                    fontWeight:
                                        isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                                trailing: isSelected
                                    ? Icon(
                                        Icons.check_circle,
                                        color: Theme.of(context).colorScheme.primary,
                                      )
                                    : null,
                                selected: isSelected,
                                onTap: () {
                                  widget.onCategorySelected(category.id);
                                  Navigator.pop(context);
                                },
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: _showCategorySelector,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.5),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                _getSelectedCategoryName(),
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: theme.textTheme.labelLarge!.fontSize,
                  fontWeight: FontWeight.bold,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
