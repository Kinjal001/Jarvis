// This file is compiled to web/drift_worker.js by:
//   dart compile js -O2 -o web/drift_worker.js web/drift_worker.dart
// It is the web worker entry point for drift's WASM SQLite implementation.
import 'package:drift/wasm.dart';

void main() {
  WasmDatabase.workerMainForOpen();
}
