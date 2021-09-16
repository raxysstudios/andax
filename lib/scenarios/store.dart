// import 'dart:io';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:path_provider/path_provider.dart';
// import 'phrases/phrase.dart';
// import 'chapters/chapter.dart';

// List<Chapter> chapters = [];
// Directory? root;

// Future<void> loadChapters() async {
//   root ??= await getApplicationDocumentsDirectory().then(
//     (r) => Directory('${r.path}/recordings'),
//   );

//   await root!.create(recursive: true);

//   chapters.clear();
//   await FirebaseFirestore.instance
//       .collection('chapters')
//       .withConverter(
//         fromFirestore: (snapshot, _) =>
//             Chapter.fromJson(snapshot.data()!, id: snapshot.id),
//         toFirestore: (Chapter object, _) => object.toJson(),
//       )
//       .get()
//       .then((d) async {
//     if (d.docs.isEmpty) return;
//     for (final doc in d.docs) {
//       final chapter = doc.data();
//       await loadPhrases(chapter);
//       chapters.add(chapter);
//     }
//   });
// }

// Future<void> loadPhrases(Chapter chapter) async {
//   return await FirebaseFirestore.instance
//       .collection('chapters/${chapter.id}/phrases')
//       .withConverter(
//         fromFirestore: (snapshot, _) => Phrase.fromJson(
//           snapshot.data()!,
//           id: snapshot.id,
//           root: root!.path,
//         ),
//         toFirestore: (Phrase object, _) => object.toJson(),
//       )
//       .get()
//       .then((d) {
//     chapter.phrases
//       ..clear()
//       ..addAll(d.docs.map((p) => p.data()))
//       ..sort((a, b) => a.index.compareTo(b.index));
//   });
// }
