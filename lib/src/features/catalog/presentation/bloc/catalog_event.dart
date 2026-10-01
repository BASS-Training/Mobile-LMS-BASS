import 'package:equatable/equatable.dart';

import 'catalog_state.dart';

sealed class CatalogEvent extends Equatable {
  const CatalogEvent();

  @override
  List<Object?> get props => [];
}

class LoadCatalogEvent extends CatalogEvent {
  const LoadCatalogEvent();
}

class SearchCatalogEvent extends CatalogEvent {
  final String query;

  const SearchCatalogEvent(this.query);

  @override
  List<Object?> get props => [query];
}

class LoadMoreCatalogEvent extends CatalogEvent {
  const LoadMoreCatalogEvent();
}

class LoadCatalogDetailEvent extends CatalogEvent {
  final String catalogId;

  const LoadCatalogDetailEvent(this.catalogId);

  @override
  List<Object?> get props => [catalogId];
}

class ChangeCatalogFilterEvent extends CatalogEvent {
  final CatalogFilter filter;

  const ChangeCatalogFilterEvent(this.filter);

  @override
  List<Object?> get props => [filter];
}

class EnrollCatalogCourseEvent extends CatalogEvent {
  final String catalogId;

  const EnrollCatalogCourseEvent(this.catalogId);

  @override
  List<Object?> get props => [catalogId];
}

class ResetCatalogEvent extends CatalogEvent {
  const ResetCatalogEvent();
}
