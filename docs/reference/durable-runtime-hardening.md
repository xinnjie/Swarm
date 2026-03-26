# Durable Runtime Non-Fork Hardening Contract

This document defines the internal runtime hardening surface for Swarm's durable graph runtime without native fork support.

## Event Schema Version

- Internal run events carry a dedicated schema-version metadata key.
- The runtime controller stamps emitted events with the current schema version when it is absent.

## Run Control APIs

### Validation

```swift
public func validateRunOptions(_ options: InternalRunOptions) throws
```

Throws typed runtime errors:

- model client missing
- tool registry missing
- checkpoint store missing
- invalid run options

### External Writes

```swift
public struct ExternalWriteRequest: Sendable {
    public var threadID: InternalThreadID
    public var writes: [AnyInternalWrite]
    public var options: InternalRunOptions
}

public func applyExternalWrites(
    _ request: ExternalWriteRequest
) async throws -> InternalRunHandle
```

Validation and failure semantics:

- unknown channel
- task-local scope write attempt
- value type mismatch
- single-value update-policy violation
- pending interrupt state

Commit semantics are all-or-nothing: no runtime state publish occurs when validation fails.

### Resume Contract Prevalidation

`resume(_:)` now performs typed prevalidation before dispatch:

- no checkpoint store
- no checkpoint
- no pending interrupt
- interrupt ID mismatch
- unsupported checkpoint format tag

## Checkpoint Capability Contract

```swift
public enum CheckpointQueryCapability: Sendable, Equatable {
    case unavailable
    case latestOnly
    case queryable
}

public func checkpointQueryCapability(
    probeThreadID: InternalThreadID = InternalThreadID("__checkpoint_capability_probe__")
) async -> CheckpointQueryCapability

public func getCheckpointHistory(
    threadID: InternalThreadID,
    limit: Int? = nil
) async throws -> [CheckpointSummary]

public func getCheckpoint(
    threadID: InternalThreadID,
    id: CheckpointID
) async throws -> InternalCheckpoint?
```

Unsupported query operations remain explicitly typed:

- unsupported query operation

## Typed Runtime State Snapshot

```swift
public struct RuntimeStateSnapshot: Sendable, Equatable {
    public let threadID: InternalThreadID
    public let runID: InternalRunID?
    public let stepIndex: Int?
    public let interruption: RuntimeInterruptionSummary?
    public let checkpointID: CheckpointID?
    public let frontier: RuntimeFrontierSummary
    public let channelState: RuntimeChannelStateSummary?
    public let eventSchemaVersion: String
    public let source: RuntimeStateSnapshotSource
}

public func getState(
    threadID: InternalThreadID
) async throws -> RuntimeStateSnapshot?
```

Missing thread behavior:

- Returns `nil` when no checkpoint, no in-memory store, and no tracked attempt state exists for `threadID`.

## Determinism + Replay Utilities

```swift
public enum RuntimeDeterminism {
    public static func projectTranscript(
        _ events: [RuntimeEvent],
        expectedSchemaVersion: String
    ) throws -> CanonicalTranscript

    public static func transcriptHash(
        _ events: [RuntimeEvent],
        expectedSchemaVersion: String
    ) throws -> String

    public static func finalStateHash(
        _ snapshot: RuntimeStateSnapshot,
        includeRuntimeIdentity: Bool = false
    ) throws -> String

    public static func firstTranscriptDiff(
        expected: CanonicalTranscript,
        actual: CanonicalTranscript
    ) -> RuntimeDeterminismDiff?

    public static func firstStateDiff(
        expected: RuntimeStateSnapshot,
        actual: RuntimeStateSnapshot,
        includeRuntimeIdentity: Bool = false
    ) -> RuntimeDeterminismDiff?
}
```

Replay compatibility checks are typed:

```swift
public enum TranscriptCompatibilityError: Error, Sendable, Equatable {
    case missingSchemaVersion(eventIndex: Int)
    case incompatibleSchemaVersion(expected: String, found: String, eventIndex: Int)
}
```

## Cancel + Checkpoint Race Classification

```swift
public enum CancelCheckpointResolution: Sendable, Equatable {
    case notCancelled
    case cancelledWithoutCheckpoint(latestCheckpointID: CheckpointID?)
    case cancelledAfterCheckpointSaved(checkpointID: CheckpointID)
}

public static func classifyCancelCheckpointRace(
    events: [RuntimeEvent],
    outcome: RuntimeOutcome
) -> CancelCheckpointResolution
```

This provides deterministic post-run classification when cancellation overlaps checkpoint persistence.
