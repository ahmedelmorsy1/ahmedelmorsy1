import 'package:flutter/material.dart';

import '../models/pitch.dart';
import '../services/api_client.dart';
import 'booking_form_screen.dart';

class PitchListScreen extends StatefulWidget {
  const PitchListScreen({
    super.key,
    required this.apiClient,
    required this.onToggleTheme,
    required this.themeMode,
  });

  final ApiClient apiClient;
  final VoidCallback onToggleTheme;
  final ThemeMode themeMode;

  @override
  State<PitchListScreen> createState() => _PitchListScreenState();
}

class _PitchListScreenState extends State<PitchListScreen> {
  final TextEditingController _searchController = TextEditingController();
  late Future<List<Pitch>> _pitchesFuture;
  List<Pitch> _cachedPitches = const [];

  @override
  void initState() {
    super.initState();
    _pitchesFuture = _loadPitches();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Pitch>> _loadPitches() async {
    final pitches = await widget.apiClient.fetchPitches();
    setState(() {
      _cachedPitches = pitches;
    });
    return pitches;
  }

  void _onSearchChanged() => setState(() {});

  List<Pitch> get _filteredPitches {
    final term = _searchController.text.trim().toLowerCase();
    if (term.isEmpty) {
      return _cachedPitches;
    }
    return _cachedPitches
        .where(
          (pitch) => pitch.name.toLowerCase().contains(term) ||
              pitch.location.toLowerCase().contains(term),
        )
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ملاعب كرة القدم'),
        actions: [
          IconButton(
            tooltip: widget.themeMode == ThemeMode.dark
                ? 'وضع نهاري'
                : 'وضع ليلي',
            onPressed: widget.onToggleTheme,
            icon: Icon(
              widget.themeMode == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                labelText: 'ابحث باسم الملعب أو المكان',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  final pitches = await _loadPitches();
                  setState(() {
                    _pitchesFuture = Future.value(pitches);
                  });
                },
                child: FutureBuilder<List<Pitch>>(
                  future: _pitchesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return _ErrorView(
                        onRetry: () {
                          setState(() {
                            _pitchesFuture = _loadPitches();
                          });
                        },
                        error: snapshot.error,
                      );
                    }

                    if (_filteredPitches.isEmpty) {
                      return const _EmptyView();
                    }

                    return ListView.separated(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: _filteredPitches.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final pitch = _filteredPitches[index];
                        return _PitchCard(
                          pitch: pitch,
                          onTap: () => _openBookingSheet(pitch),
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openBookingSheet(Pitch pitch) async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return BookingFormSheet(
          apiClient: widget.apiClient,
          pitch: pitch,
        );
      },
    );

    if (created == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم إرسال حجزك لملعب ${pitch.name} بنجاح!'),
        ),
      );
    }
  }
}

class _PitchCard extends StatelessWidget {
  const _PitchCard({required this.pitch, required this.onTap});

  final Pitch pitch;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      pitch.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.place, size: 18),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      pitch.location,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _ChipWithIcon(
                    icon: Icons.price_change_outlined,
                    label: '${pitch.pricePerHour.toStringAsFixed(0)} EGP/ساعة',
                  ),
                  _ChipWithIcon(
                    icon: Icons.sports_soccer,
                    label: pitch.surfaceType,
                  ),
                  for (final amenity in pitch.amenities)
                    _ChipWithIcon(
                      icon: Icons.check_circle_outline,
                      label: amenity,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChipWithIcon extends StatelessWidget {
  const _ChipWithIcon({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.sports_soccer_outlined,
            size: 48,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 12),
          const Text('لا توجد ملاعب مطابقة للبحث الحالي.'),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.error, required this.onRetry});

  final Object? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.wifi_off, size: 48),
          const SizedBox(height: 12),
          Text(
            'تعذر تحميل الملاعب.\n${error ?? ''}',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }
}
