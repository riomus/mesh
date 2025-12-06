import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';
import '../../models/mesh_node_view.dart';
import '../../meshtastic/model/meshtastic_models.dart';

class NodesState extends Equatable {
  final List<MeshNodeView> nodes;
  final NodeNum? localNodeId;
  final double? customRefLat;
  final double? customRefLon;

  const NodesState({
    this.nodes = const [],
    this.localNodeId,
    this.customRefLat,
    this.customRefLon,
  });

  NodesState copyWith({
    List<MeshNodeView>? nodes,
    NodeNum? localNodeId,
    double? customRefLat,
    double? customRefLon,
  }) {
    return NodesState(
      nodes: nodes ?? this.nodes,
      localNodeId: localNodeId ?? this.localNodeId,
      customRefLat: customRefLat ?? this.customRefLat,
      customRefLon: customRefLon ?? this.customRefLon,
    );
  }

  MeshNodeView? getNode(int? id) {
    if (id == null) return null;
    return nodes.firstWhereOrNull((n) => n.num == id);
  }

  @override
  List<Object?> get props => [nodes, localNodeId, customRefLat, customRefLon];
}
