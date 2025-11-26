import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:heroes_app/assets/app_constants.dart';
import 'package:heroes_app/assets/app_methods.dart';

class RankItem {
  final String value;
  final String displayName;
  final String category;
  final String subCategory;

  RankItem({
    required this.value,
    required this.displayName,
    required this.category,
    required this.subCategory,
  });
}

class SearchableRankSelector extends StatefulWidget {
  final String? selectedRank;
  final Function(String?) onRankSelected;
  final String labelText;
  final String hintText;
  final String? Function(String?)? validator;

  const SearchableRankSelector({
    super.key,
    required this.selectedRank,
    required this.onRankSelected,
    required this.labelText,
    required this.hintText,
    this.validator,
  });

  @override
  State<SearchableRankSelector> createState() => _SearchableRankSelectorState();
}

class _SearchableRankSelectorState extends State<SearchableRankSelector> {
  final TextEditingController _searchController = TextEditingController();
  List<RankItem> _allRanks = [];
  List<RankItem> _filteredRanks = [];
  final locator = GetIt.instance;

  @override
  void initState() {
    super.initState();
    _loadRanks();
    _searchController.addListener(_filterRanks);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadRanks() {
    final ranksMap = locator.get<AppConstants>().ranks;
    final List<RankItem> ranks = [];

    ranksMap.forEach((category, subCategories) {
      subCategories.forEach((subCategory, options) {
        for (var option in options) {
          final value = "${category}_${subCategory}_$option";
          ranks.add(RankItem(
            value: value,
            displayName: locator.get<AppMethods>().capitalize(option),
            category: locator.get<AppMethods>().capitalize(category),
            subCategory: locator.get<AppMethods>().capitalize(subCategory),
          ));
        }
      });
    });

    setState(() {
      _allRanks = ranks;
      _filteredRanks = ranks;
    });
  }

  void _filterRanks() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredRanks = _allRanks;
      } else {
        _filteredRanks = _allRanks.where((rank) {
          return rank.displayName.toLowerCase().contains(query) ||
              rank.category.toLowerCase().contains(query) ||
              rank.subCategory.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  String _getSelectedRankDisplay() {
    if (widget.selectedRank == null || widget.selectedRank!.isEmpty) {
      return widget.hintText;
    }
    final rank = _allRanks.firstWhere(
      (r) => r.value == widget.selectedRank,
      orElse: () => RankItem(
        value: '',
        displayName: widget.hintText,
        category: '',
        subCategory: '',
      ),
    );
    return rank.displayName;
  }

  void _showRankSelector() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
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
                  'Seleccionar Rango',
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
                    hintText: 'Buscar rango...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                  ),
                  autofocus: false,
                ),
              ),
              const Divider(height: 1),
              // Ranks list
              Expanded(
                child: _filteredRanks.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'No se encontraron rangos',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: scrollController,
                        itemCount: _filteredRanks.length,
                        itemBuilder: (context, index) {
                          final rank = _filteredRanks[index];
                          final isSelected = widget.selectedRank == rank.value;

                          return ListTile(
                            title: Text(
                              rank.displayName,
                              style: TextStyle(
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            subtitle: Text('${rank.category} - ${rank.subCategory}'),
                            trailing: isSelected
                                ? Icon(
                                    Icons.check_circle,
                                    color: Theme.of(context).colorScheme.primary,
                                  )
                                : null,
                            selected: isSelected,
                            onTap: () {
                              widget.onRankSelected(rank.value);
                              Navigator.pop(context);
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    ).whenComplete(() {
      // Clear search when modal closes
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final errorText = widget.validator?.call(widget.selectedRank);
    final hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: _showRankSelector,
          borderRadius: BorderRadius.circular(4),
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: widget.labelText,
              hintText: widget.hintText,
              border: const OutlineInputBorder(),
              errorText: hasError ? errorText : null,
              suffixIcon: Icon(
                Icons.arrow_drop_down,
                color: hasError
                    ? theme.colorScheme.error
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
            child: Text(
              _getSelectedRankDisplay(),
              style: TextStyle(
                color: widget.selectedRank == null || widget.selectedRank!.isEmpty
                    ? theme.hintColor
                    : theme.colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
