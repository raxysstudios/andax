import 'dart:collection';

import '../models/actor_command.dart';

/// The journal stores the pending actions, similar to
/// [journaling file systems](https://en.wikipedia.org/wiki/Journaling_file_system).
/// The intention is for widgest and subpages to be able record changes without
///  actually applying them until the user confirms all of the changes.
/// It is also useful for undo/redo, and to not display the "unsaved changes"
///   warning if the user doesn't make any changes.
class Journal {
  final Queue<ActorCommand> actorChanges = Queue();

  void applyChanges() {
    for (final change in actorChanges) {
      change.when(
        create: (type) {
          // create actor
        },
        update: (id, type) {
          // update actor
        },
        delete: (id) {
          // delete actor
        },
      );
    }
  }
}
