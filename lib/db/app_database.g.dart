// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TasksTable extends Tasks with TableInfo<$TasksTable, Task> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadMeta =
      const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
      'payload', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _priorityMeta =
      const VerificationMeta('priority');
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
      'priority', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _scheduledAtMeta =
      const VerificationMeta('scheduledAt');
  @override
  late final GeneratedColumn<int> scheduledAt = GeneratedColumn<int>(
      'scheduled_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _completedAtMeta =
      const VerificationMeta('completedAt');
  @override
  late final GeneratedColumn<int> completedAt = GeneratedColumn<int>(
      'completed_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _retryCountMeta =
      const VerificationMeta('retryCount');
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
      'retry_count', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _maxRetriesMeta =
      const VerificationMeta('maxRetries');
  @override
  late final GeneratedColumn<int> maxRetries = GeneratedColumn<int>(
      'max_retries', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(3));
  static const VerificationMeta _errorMeta = const VerificationMeta('error');
  @override
  late final GeneratedColumn<String> error = GeneratedColumn<String>(
      'error', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _resultMeta = const VerificationMeta('result');
  @override
  late final GeneratedColumn<String> result = GeneratedColumn<String>(
      'result', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _bizIdMeta = const VerificationMeta('bizId');
  @override
  late final GeneratedColumn<String> bizId = GeneratedColumn<String>(
      'biz_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _dependenciesMeta =
      const VerificationMeta('dependencies');
  @override
  late final GeneratedColumn<String> dependencies = GeneratedColumn<String>(
      'dependencies', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        type,
        payload,
        status,
        priority,
        createdAt,
        scheduledAt,
        completedAt,
        updatedAt,
        retryCount,
        maxRetries,
        error,
        result,
        bizId,
        dependencies
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(Insertable<Task> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta,
          payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('priority')) {
      context.handle(_priorityMeta,
          priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('scheduled_at')) {
      context.handle(
          _scheduledAtMeta,
          scheduledAt.isAcceptableOrUnknown(
              data['scheduled_at']!, _scheduledAtMeta));
    }
    if (data.containsKey('completed_at')) {
      context.handle(
          _completedAtMeta,
          completedAt.isAcceptableOrUnknown(
              data['completed_at']!, _completedAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('retry_count')) {
      context.handle(
          _retryCountMeta,
          retryCount.isAcceptableOrUnknown(
              data['retry_count']!, _retryCountMeta));
    }
    if (data.containsKey('max_retries')) {
      context.handle(
          _maxRetriesMeta,
          maxRetries.isAcceptableOrUnknown(
              data['max_retries']!, _maxRetriesMeta));
    }
    if (data.containsKey('error')) {
      context.handle(
          _errorMeta, error.isAcceptableOrUnknown(data['error']!, _errorMeta));
    }
    if (data.containsKey('result')) {
      context.handle(_resultMeta,
          result.isAcceptableOrUnknown(data['result']!, _resultMeta));
    }
    if (data.containsKey('biz_id')) {
      context.handle(
          _bizIdMeta, bizId.isAcceptableOrUnknown(data['biz_id']!, _bizIdMeta));
    }
    if (data.containsKey('dependencies')) {
      context.handle(
          _dependenciesMeta,
          dependencies.isAcceptableOrUnknown(
              data['dependencies']!, _dependenciesMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Task map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Task(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      priority: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}priority'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at']),
      scheduledAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}scheduled_at']),
      completedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}completed_at']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at']),
      retryCount: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}retry_count'])!,
      maxRetries: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}max_retries'])!,
      error: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}error']),
      result: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}result']),
      bizId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}biz_id']),
      dependencies: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}dependencies']),
    );
  }

  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }
}

class Task extends DataClass implements Insertable<Task> {
  final String id;
  final String type;
  final String? payload;
  final String status;
  final int priority;
  final int? createdAt;
  final int? scheduledAt;
  final int? completedAt;
  final int? updatedAt;
  final int retryCount;
  final int maxRetries;
  final String? error;
  final String? result;
  final String? bizId;
  final String? dependencies;
  const Task(
      {required this.id,
      required this.type,
      this.payload,
      required this.status,
      required this.priority,
      this.createdAt,
      this.scheduledAt,
      this.completedAt,
      this.updatedAt,
      required this.retryCount,
      required this.maxRetries,
      this.error,
      this.result,
      this.bizId,
      this.dependencies});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || payload != null) {
      map['payload'] = Variable<String>(payload);
    }
    map['status'] = Variable<String>(status);
    map['priority'] = Variable<int>(priority);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<int>(createdAt);
    }
    if (!nullToAbsent || scheduledAt != null) {
      map['scheduled_at'] = Variable<int>(scheduledAt);
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<int>(completedAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<int>(updatedAt);
    }
    map['retry_count'] = Variable<int>(retryCount);
    map['max_retries'] = Variable<int>(maxRetries);
    if (!nullToAbsent || error != null) {
      map['error'] = Variable<String>(error);
    }
    if (!nullToAbsent || result != null) {
      map['result'] = Variable<String>(result);
    }
    if (!nullToAbsent || bizId != null) {
      map['biz_id'] = Variable<String>(bizId);
    }
    if (!nullToAbsent || dependencies != null) {
      map['dependencies'] = Variable<String>(dependencies);
    }
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(id),
      type: Value(type),
      payload: payload == null && nullToAbsent
          ? const Value.absent()
          : Value(payload),
      status: Value(status),
      priority: Value(priority),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      scheduledAt: scheduledAt == null && nullToAbsent
          ? const Value.absent()
          : Value(scheduledAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      retryCount: Value(retryCount),
      maxRetries: Value(maxRetries),
      error:
          error == null && nullToAbsent ? const Value.absent() : Value(error),
      result:
          result == null && nullToAbsent ? const Value.absent() : Value(result),
      bizId:
          bizId == null && nullToAbsent ? const Value.absent() : Value(bizId),
      dependencies: dependencies == null && nullToAbsent
          ? const Value.absent()
          : Value(dependencies),
    );
  }

  factory Task.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Task(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      payload: serializer.fromJson<String?>(json['payload']),
      status: serializer.fromJson<String>(json['status']),
      priority: serializer.fromJson<int>(json['priority']),
      createdAt: serializer.fromJson<int?>(json['createdAt']),
      scheduledAt: serializer.fromJson<int?>(json['scheduledAt']),
      completedAt: serializer.fromJson<int?>(json['completedAt']),
      updatedAt: serializer.fromJson<int?>(json['updatedAt']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      maxRetries: serializer.fromJson<int>(json['maxRetries']),
      error: serializer.fromJson<String?>(json['error']),
      result: serializer.fromJson<String?>(json['result']),
      bizId: serializer.fromJson<String?>(json['bizId']),
      dependencies: serializer.fromJson<String?>(json['dependencies']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'payload': serializer.toJson<String?>(payload),
      'status': serializer.toJson<String>(status),
      'priority': serializer.toJson<int>(priority),
      'createdAt': serializer.toJson<int?>(createdAt),
      'scheduledAt': serializer.toJson<int?>(scheduledAt),
      'completedAt': serializer.toJson<int?>(completedAt),
      'updatedAt': serializer.toJson<int?>(updatedAt),
      'retryCount': serializer.toJson<int>(retryCount),
      'maxRetries': serializer.toJson<int>(maxRetries),
      'error': serializer.toJson<String?>(error),
      'result': serializer.toJson<String?>(result),
      'bizId': serializer.toJson<String?>(bizId),
      'dependencies': serializer.toJson<String?>(dependencies),
    };
  }

  Task copyWith(
          {String? id,
          String? type,
          Value<String?> payload = const Value.absent(),
          String? status,
          int? priority,
          Value<int?> createdAt = const Value.absent(),
          Value<int?> scheduledAt = const Value.absent(),
          Value<int?> completedAt = const Value.absent(),
          Value<int?> updatedAt = const Value.absent(),
          int? retryCount,
          int? maxRetries,
          Value<String?> error = const Value.absent(),
          Value<String?> result = const Value.absent(),
          Value<String?> bizId = const Value.absent(),
          Value<String?> dependencies = const Value.absent()}) =>
      Task(
        id: id ?? this.id,
        type: type ?? this.type,
        payload: payload.present ? payload.value : this.payload,
        status: status ?? this.status,
        priority: priority ?? this.priority,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        scheduledAt: scheduledAt.present ? scheduledAt.value : this.scheduledAt,
        completedAt: completedAt.present ? completedAt.value : this.completedAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
        retryCount: retryCount ?? this.retryCount,
        maxRetries: maxRetries ?? this.maxRetries,
        error: error.present ? error.value : this.error,
        result: result.present ? result.value : this.result,
        bizId: bizId.present ? bizId.value : this.bizId,
        dependencies:
            dependencies.present ? dependencies.value : this.dependencies,
      );
  Task copyWithCompanion(TasksCompanion data) {
    return Task(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      payload: data.payload.present ? data.payload.value : this.payload,
      status: data.status.present ? data.status.value : this.status,
      priority: data.priority.present ? data.priority.value : this.priority,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      scheduledAt:
          data.scheduledAt.present ? data.scheduledAt.value : this.scheduledAt,
      completedAt:
          data.completedAt.present ? data.completedAt.value : this.completedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      retryCount:
          data.retryCount.present ? data.retryCount.value : this.retryCount,
      maxRetries:
          data.maxRetries.present ? data.maxRetries.value : this.maxRetries,
      error: data.error.present ? data.error.value : this.error,
      result: data.result.present ? data.result.value : this.result,
      bizId: data.bizId.present ? data.bizId.value : this.bizId,
      dependencies: data.dependencies.present
          ? data.dependencies.value
          : this.dependencies,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Task(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('payload: $payload, ')
          ..write('status: $status, ')
          ..write('priority: $priority, ')
          ..write('createdAt: $createdAt, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('maxRetries: $maxRetries, ')
          ..write('error: $error, ')
          ..write('result: $result, ')
          ..write('bizId: $bizId, ')
          ..write('dependencies: $dependencies')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      type,
      payload,
      status,
      priority,
      createdAt,
      scheduledAt,
      completedAt,
      updatedAt,
      retryCount,
      maxRetries,
      error,
      result,
      bizId,
      dependencies);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Task &&
          other.id == this.id &&
          other.type == this.type &&
          other.payload == this.payload &&
          other.status == this.status &&
          other.priority == this.priority &&
          other.createdAt == this.createdAt &&
          other.scheduledAt == this.scheduledAt &&
          other.completedAt == this.completedAt &&
          other.updatedAt == this.updatedAt &&
          other.retryCount == this.retryCount &&
          other.maxRetries == this.maxRetries &&
          other.error == this.error &&
          other.result == this.result &&
          other.bizId == this.bizId &&
          other.dependencies == this.dependencies);
}

class TasksCompanion extends UpdateCompanion<Task> {
  final Value<String> id;
  final Value<String> type;
  final Value<String?> payload;
  final Value<String> status;
  final Value<int> priority;
  final Value<int?> createdAt;
  final Value<int?> scheduledAt;
  final Value<int?> completedAt;
  final Value<int?> updatedAt;
  final Value<int> retryCount;
  final Value<int> maxRetries;
  final Value<String?> error;
  final Value<String?> result;
  final Value<String?> bizId;
  final Value<String?> dependencies;
  final Value<int> rowid;
  const TasksCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.payload = const Value.absent(),
    this.status = const Value.absent(),
    this.priority = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.scheduledAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.maxRetries = const Value.absent(),
    this.error = const Value.absent(),
    this.result = const Value.absent(),
    this.bizId = const Value.absent(),
    this.dependencies = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TasksCompanion.insert({
    required String id,
    required String type,
    this.payload = const Value.absent(),
    required String status,
    this.priority = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.scheduledAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.maxRetries = const Value.absent(),
    this.error = const Value.absent(),
    this.result = const Value.absent(),
    this.bizId = const Value.absent(),
    this.dependencies = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        type = Value(type),
        status = Value(status);
  static Insertable<Task> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<String>? payload,
    Expression<String>? status,
    Expression<int>? priority,
    Expression<int>? createdAt,
    Expression<int>? scheduledAt,
    Expression<int>? completedAt,
    Expression<int>? updatedAt,
    Expression<int>? retryCount,
    Expression<int>? maxRetries,
    Expression<String>? error,
    Expression<String>? result,
    Expression<String>? bizId,
    Expression<String>? dependencies,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (payload != null) 'payload': payload,
      if (status != null) 'status': status,
      if (priority != null) 'priority': priority,
      if (createdAt != null) 'created_at': createdAt,
      if (scheduledAt != null) 'scheduled_at': scheduledAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (retryCount != null) 'retry_count': retryCount,
      if (maxRetries != null) 'max_retries': maxRetries,
      if (error != null) 'error': error,
      if (result != null) 'result': result,
      if (bizId != null) 'biz_id': bizId,
      if (dependencies != null) 'dependencies': dependencies,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TasksCompanion copyWith(
      {Value<String>? id,
      Value<String>? type,
      Value<String?>? payload,
      Value<String>? status,
      Value<int>? priority,
      Value<int?>? createdAt,
      Value<int?>? scheduledAt,
      Value<int?>? completedAt,
      Value<int?>? updatedAt,
      Value<int>? retryCount,
      Value<int>? maxRetries,
      Value<String?>? error,
      Value<String?>? result,
      Value<String?>? bizId,
      Value<String?>? dependencies,
      Value<int>? rowid}) {
    return TasksCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      payload: payload ?? this.payload,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      completedAt: completedAt ?? this.completedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      retryCount: retryCount ?? this.retryCount,
      maxRetries: maxRetries ?? this.maxRetries,
      error: error ?? this.error,
      result: result ?? this.result,
      bizId: bizId ?? this.bizId,
      dependencies: dependencies ?? this.dependencies,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (scheduledAt.present) {
      map['scheduled_at'] = Variable<int>(scheduledAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<int>(completedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (maxRetries.present) {
      map['max_retries'] = Variable<int>(maxRetries.value);
    }
    if (error.present) {
      map['error'] = Variable<String>(error.value);
    }
    if (result.present) {
      map['result'] = Variable<String>(result.value);
    }
    if (bizId.present) {
      map['biz_id'] = Variable<String>(bizId.value);
    }
    if (dependencies.present) {
      map['dependencies'] = Variable<String>(dependencies.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('payload: $payload, ')
          ..write('status: $status, ')
          ..write('priority: $priority, ')
          ..write('createdAt: $createdAt, ')
          ..write('scheduledAt: $scheduledAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('retryCount: $retryCount, ')
          ..write('maxRetries: $maxRetries, ')
          ..write('error: $error, ')
          ..write('result: $result, ')
          ..write('bizId: $bizId, ')
          ..write('dependencies: $dependencies, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $KvStoreTable extends KvStore with TableInfo<$KvStoreTable, KvStoreData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KvStoreTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _bucketMeta = const VerificationMeta('bucket');
  @override
  late final GeneratedColumn<String> bucket = GeneratedColumn<String>(
      'bucket', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [key, value, bucket, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'kv_store';
  @override
  VerificationContext validateIntegrity(Insertable<KvStoreData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    }
    if (data.containsKey('bucket')) {
      context.handle(_bucketMeta,
          bucket.isAcceptableOrUnknown(data['bucket']!, _bucketMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  KvStoreData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KvStoreData(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value']),
      bucket: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}bucket']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at']),
    );
  }

  @override
  $KvStoreTable createAlias(String alias) {
    return $KvStoreTable(attachedDatabase, alias);
  }
}

class KvStoreData extends DataClass implements Insertable<KvStoreData> {
  final String key;
  final String? value;
  final String? bucket;
  final int? updatedAt;
  const KvStoreData(
      {required this.key, this.value, this.bucket, this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    if (!nullToAbsent || value != null) {
      map['value'] = Variable<String>(value);
    }
    if (!nullToAbsent || bucket != null) {
      map['bucket'] = Variable<String>(bucket);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<int>(updatedAt);
    }
    return map;
  }

  KvStoreCompanion toCompanion(bool nullToAbsent) {
    return KvStoreCompanion(
      key: Value(key),
      value:
          value == null && nullToAbsent ? const Value.absent() : Value(value),
      bucket:
          bucket == null && nullToAbsent ? const Value.absent() : Value(bucket),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory KvStoreData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KvStoreData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String?>(json['value']),
      bucket: serializer.fromJson<String?>(json['bucket']),
      updatedAt: serializer.fromJson<int?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String?>(value),
      'bucket': serializer.toJson<String?>(bucket),
      'updatedAt': serializer.toJson<int?>(updatedAt),
    };
  }

  KvStoreData copyWith(
          {String? key,
          Value<String?> value = const Value.absent(),
          Value<String?> bucket = const Value.absent(),
          Value<int?> updatedAt = const Value.absent()}) =>
      KvStoreData(
        key: key ?? this.key,
        value: value.present ? value.value : this.value,
        bucket: bucket.present ? bucket.value : this.bucket,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
      );
  KvStoreData copyWithCompanion(KvStoreCompanion data) {
    return KvStoreData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      bucket: data.bucket.present ? data.bucket.value : this.bucket,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KvStoreData(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('bucket: $bucket, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, bucket, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KvStoreData &&
          other.key == this.key &&
          other.value == this.value &&
          other.bucket == this.bucket &&
          other.updatedAt == this.updatedAt);
}

class KvStoreCompanion extends UpdateCompanion<KvStoreData> {
  final Value<String> key;
  final Value<String?> value;
  final Value<String?> bucket;
  final Value<int?> updatedAt;
  final Value<int> rowid;
  const KvStoreCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.bucket = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  KvStoreCompanion.insert({
    required String key,
    this.value = const Value.absent(),
    this.bucket = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key);
  static Insertable<KvStoreData> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<String>? bucket,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (bucket != null) 'bucket': bucket,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  KvStoreCompanion copyWith(
      {Value<String>? key,
      Value<String?>? value,
      Value<String?>? bucket,
      Value<int?>? updatedAt,
      Value<int>? rowid}) {
    return KvStoreCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      bucket: bucket ?? this.bucket,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (bucket.present) {
      map['bucket'] = Variable<String>(bucket.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KvStoreCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('bucket: $bucket, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AgentActivityMessagesTable extends AgentActivityMessages
    with TableInfo<$AgentActivityMessagesTable, AgentActivityMessage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AgentActivityMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
      'icon', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _agentNameMeta =
      const VerificationMeta('agentName');
  @override
  late final GeneratedColumn<String> agentName = GeneratedColumn<String>(
      'agent_name', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('Unknown'));
  static const VerificationMeta _agentIdMeta =
      const VerificationMeta('agentId');
  @override
  late final GeneratedColumn<String> agentId = GeneratedColumn<String>(
      'agent_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sceneMeta = const VerificationMeta('scene');
  @override
  late final GeneratedColumn<String> scene = GeneratedColumn<String>(
      'scene', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sceneIdMeta =
      const VerificationMeta('sceneId');
  @override
  late final GeneratedColumn<String> sceneId = GeneratedColumn<String>(
      'scene_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        type,
        title,
        content,
        icon,
        agentName,
        agentId,
        scene,
        sceneId,
        userId,
        timestamp
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'agent_activity_messages';
  @override
  VerificationContext validateIntegrity(
      Insertable<AgentActivityMessage> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    }
    if (data.containsKey('icon')) {
      context.handle(
          _iconMeta, icon.isAcceptableOrUnknown(data['icon']!, _iconMeta));
    }
    if (data.containsKey('agent_name')) {
      context.handle(_agentNameMeta,
          agentName.isAcceptableOrUnknown(data['agent_name']!, _agentNameMeta));
    }
    if (data.containsKey('agent_id')) {
      context.handle(_agentIdMeta,
          agentId.isAcceptableOrUnknown(data['agent_id']!, _agentIdMeta));
    }
    if (data.containsKey('scene')) {
      context.handle(
          _sceneMeta, scene.isAcceptableOrUnknown(data['scene']!, _sceneMeta));
    }
    if (data.containsKey('scene_id')) {
      context.handle(_sceneIdMeta,
          sceneId.isAcceptableOrUnknown(data['scene_id']!, _sceneIdMeta));
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AgentActivityMessage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AgentActivityMessage(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content']),
      icon: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon']),
      agentName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}agent_name'])!,
      agentId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}agent_id']),
      scene: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}scene']),
      sceneId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}scene_id']),
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id']),
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}timestamp'])!,
    );
  }

  @override
  $AgentActivityMessagesTable createAlias(String alias) {
    return $AgentActivityMessagesTable(attachedDatabase, alias);
  }
}

class AgentActivityMessage extends DataClass
    implements Insertable<AgentActivityMessage> {
  final int id;
  final String type;
  final String title;
  final String? content;
  final String? icon;
  final String agentName;
  final String? agentId;
  final String? scene;
  final String? sceneId;
  final String? userId;
  final DateTime timestamp;
  const AgentActivityMessage(
      {required this.id,
      required this.type,
      required this.title,
      this.content,
      this.icon,
      required this.agentName,
      this.agentId,
      this.scene,
      this.sceneId,
      this.userId,
      required this.timestamp});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['type'] = Variable<String>(type);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || content != null) {
      map['content'] = Variable<String>(content);
    }
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<String>(icon);
    }
    map['agent_name'] = Variable<String>(agentName);
    if (!nullToAbsent || agentId != null) {
      map['agent_id'] = Variable<String>(agentId);
    }
    if (!nullToAbsent || scene != null) {
      map['scene'] = Variable<String>(scene);
    }
    if (!nullToAbsent || sceneId != null) {
      map['scene_id'] = Variable<String>(sceneId);
    }
    if (!nullToAbsent || userId != null) {
      map['user_id'] = Variable<String>(userId);
    }
    map['timestamp'] = Variable<DateTime>(timestamp);
    return map;
  }

  AgentActivityMessagesCompanion toCompanion(bool nullToAbsent) {
    return AgentActivityMessagesCompanion(
      id: Value(id),
      type: Value(type),
      title: Value(title),
      content: content == null && nullToAbsent
          ? const Value.absent()
          : Value(content),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
      agentName: Value(agentName),
      agentId: agentId == null && nullToAbsent
          ? const Value.absent()
          : Value(agentId),
      scene:
          scene == null && nullToAbsent ? const Value.absent() : Value(scene),
      sceneId: sceneId == null && nullToAbsent
          ? const Value.absent()
          : Value(sceneId),
      userId:
          userId == null && nullToAbsent ? const Value.absent() : Value(userId),
      timestamp: Value(timestamp),
    );
  }

  factory AgentActivityMessage.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AgentActivityMessage(
      id: serializer.fromJson<int>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      title: serializer.fromJson<String>(json['title']),
      content: serializer.fromJson<String?>(json['content']),
      icon: serializer.fromJson<String?>(json['icon']),
      agentName: serializer.fromJson<String>(json['agentName']),
      agentId: serializer.fromJson<String?>(json['agentId']),
      scene: serializer.fromJson<String?>(json['scene']),
      sceneId: serializer.fromJson<String?>(json['sceneId']),
      userId: serializer.fromJson<String?>(json['userId']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'type': serializer.toJson<String>(type),
      'title': serializer.toJson<String>(title),
      'content': serializer.toJson<String?>(content),
      'icon': serializer.toJson<String?>(icon),
      'agentName': serializer.toJson<String>(agentName),
      'agentId': serializer.toJson<String?>(agentId),
      'scene': serializer.toJson<String?>(scene),
      'sceneId': serializer.toJson<String?>(sceneId),
      'userId': serializer.toJson<String?>(userId),
      'timestamp': serializer.toJson<DateTime>(timestamp),
    };
  }

  AgentActivityMessage copyWith(
          {int? id,
          String? type,
          String? title,
          Value<String?> content = const Value.absent(),
          Value<String?> icon = const Value.absent(),
          String? agentName,
          Value<String?> agentId = const Value.absent(),
          Value<String?> scene = const Value.absent(),
          Value<String?> sceneId = const Value.absent(),
          Value<String?> userId = const Value.absent(),
          DateTime? timestamp}) =>
      AgentActivityMessage(
        id: id ?? this.id,
        type: type ?? this.type,
        title: title ?? this.title,
        content: content.present ? content.value : this.content,
        icon: icon.present ? icon.value : this.icon,
        agentName: agentName ?? this.agentName,
        agentId: agentId.present ? agentId.value : this.agentId,
        scene: scene.present ? scene.value : this.scene,
        sceneId: sceneId.present ? sceneId.value : this.sceneId,
        userId: userId.present ? userId.value : this.userId,
        timestamp: timestamp ?? this.timestamp,
      );
  AgentActivityMessage copyWithCompanion(AgentActivityMessagesCompanion data) {
    return AgentActivityMessage(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      title: data.title.present ? data.title.value : this.title,
      content: data.content.present ? data.content.value : this.content,
      icon: data.icon.present ? data.icon.value : this.icon,
      agentName: data.agentName.present ? data.agentName.value : this.agentName,
      agentId: data.agentId.present ? data.agentId.value : this.agentId,
      scene: data.scene.present ? data.scene.value : this.scene,
      sceneId: data.sceneId.present ? data.sceneId.value : this.sceneId,
      userId: data.userId.present ? data.userId.value : this.userId,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AgentActivityMessage(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('icon: $icon, ')
          ..write('agentName: $agentName, ')
          ..write('agentId: $agentId, ')
          ..write('scene: $scene, ')
          ..write('sceneId: $sceneId, ')
          ..write('userId: $userId, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, type, title, content, icon, agentName,
      agentId, scene, sceneId, userId, timestamp);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AgentActivityMessage &&
          other.id == this.id &&
          other.type == this.type &&
          other.title == this.title &&
          other.content == this.content &&
          other.icon == this.icon &&
          other.agentName == this.agentName &&
          other.agentId == this.agentId &&
          other.scene == this.scene &&
          other.sceneId == this.sceneId &&
          other.userId == this.userId &&
          other.timestamp == this.timestamp);
}

class AgentActivityMessagesCompanion
    extends UpdateCompanion<AgentActivityMessage> {
  final Value<int> id;
  final Value<String> type;
  final Value<String> title;
  final Value<String?> content;
  final Value<String?> icon;
  final Value<String> agentName;
  final Value<String?> agentId;
  final Value<String?> scene;
  final Value<String?> sceneId;
  final Value<String?> userId;
  final Value<DateTime> timestamp;
  const AgentActivityMessagesCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.title = const Value.absent(),
    this.content = const Value.absent(),
    this.icon = const Value.absent(),
    this.agentName = const Value.absent(),
    this.agentId = const Value.absent(),
    this.scene = const Value.absent(),
    this.sceneId = const Value.absent(),
    this.userId = const Value.absent(),
    this.timestamp = const Value.absent(),
  });
  AgentActivityMessagesCompanion.insert({
    this.id = const Value.absent(),
    required String type,
    required String title,
    this.content = const Value.absent(),
    this.icon = const Value.absent(),
    this.agentName = const Value.absent(),
    this.agentId = const Value.absent(),
    this.scene = const Value.absent(),
    this.sceneId = const Value.absent(),
    this.userId = const Value.absent(),
    required DateTime timestamp,
  })  : type = Value(type),
        title = Value(title),
        timestamp = Value(timestamp);
  static Insertable<AgentActivityMessage> custom({
    Expression<int>? id,
    Expression<String>? type,
    Expression<String>? title,
    Expression<String>? content,
    Expression<String>? icon,
    Expression<String>? agentName,
    Expression<String>? agentId,
    Expression<String>? scene,
    Expression<String>? sceneId,
    Expression<String>? userId,
    Expression<DateTime>? timestamp,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (title != null) 'title': title,
      if (content != null) 'content': content,
      if (icon != null) 'icon': icon,
      if (agentName != null) 'agent_name': agentName,
      if (agentId != null) 'agent_id': agentId,
      if (scene != null) 'scene': scene,
      if (sceneId != null) 'scene_id': sceneId,
      if (userId != null) 'user_id': userId,
      if (timestamp != null) 'timestamp': timestamp,
    });
  }

  AgentActivityMessagesCompanion copyWith(
      {Value<int>? id,
      Value<String>? type,
      Value<String>? title,
      Value<String?>? content,
      Value<String?>? icon,
      Value<String>? agentName,
      Value<String?>? agentId,
      Value<String?>? scene,
      Value<String?>? sceneId,
      Value<String?>? userId,
      Value<DateTime>? timestamp}) {
    return AgentActivityMessagesCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      content: content ?? this.content,
      icon: icon ?? this.icon,
      agentName: agentName ?? this.agentName,
      agentId: agentId ?? this.agentId,
      scene: scene ?? this.scene,
      sceneId: sceneId ?? this.sceneId,
      userId: userId ?? this.userId,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (agentName.present) {
      map['agent_name'] = Variable<String>(agentName.value);
    }
    if (agentId.present) {
      map['agent_id'] = Variable<String>(agentId.value);
    }
    if (scene.present) {
      map['scene'] = Variable<String>(scene.value);
    }
    if (sceneId.present) {
      map['scene_id'] = Variable<String>(sceneId.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AgentActivityMessagesCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('icon: $icon, ')
          ..write('agentName: $agentName, ')
          ..write('agentId: $agentId, ')
          ..write('scene: $scene, ')
          ..write('sceneId: $sceneId, ')
          ..write('userId: $userId, ')
          ..write('timestamp: $timestamp')
          ..write(')'))
        .toString();
  }
}

class $CardCacheTable extends CardCache
    with TableInfo<$CardCacheTable, CardCacheData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CardCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _factIdMeta = const VerificationMeta('factId');
  @override
  late final GeneratedColumn<String> factId = GeneratedColumn<String>(
      'fact_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _cardPathMeta =
      const VerificationMeta('cardPath');
  @override
  late final GeneratedColumn<String> cardPath = GeneratedColumn<String>(
      'card_path', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<int> timestamp = GeneratedColumn<int>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
      'tags', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [factId, cardPath, timestamp, tags];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'card_cache';
  @override
  VerificationContext validateIntegrity(Insertable<CardCacheData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('fact_id')) {
      context.handle(_factIdMeta,
          factId.isAcceptableOrUnknown(data['fact_id']!, _factIdMeta));
    } else if (isInserting) {
      context.missing(_factIdMeta);
    }
    if (data.containsKey('card_path')) {
      context.handle(_cardPathMeta,
          cardPath.isAcceptableOrUnknown(data['card_path']!, _cardPathMeta));
    } else if (isInserting) {
      context.missing(_cardPathMeta);
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('tags')) {
      context.handle(
          _tagsMeta, tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta));
    } else if (isInserting) {
      context.missing(_tagsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {factId};
  @override
  CardCacheData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CardCacheData(
      factId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}fact_id'])!,
      cardPath: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}card_path'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}timestamp'])!,
      tags: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}tags'])!,
    );
  }

  @override
  $CardCacheTable createAlias(String alias) {
    return $CardCacheTable(attachedDatabase, alias);
  }
}

class CardCacheData extends DataClass implements Insertable<CardCacheData> {
  final String factId;
  final String cardPath;
  final int timestamp;
  final String tags;
  const CardCacheData(
      {required this.factId,
      required this.cardPath,
      required this.timestamp,
      required this.tags});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['fact_id'] = Variable<String>(factId);
    map['card_path'] = Variable<String>(cardPath);
    map['timestamp'] = Variable<int>(timestamp);
    map['tags'] = Variable<String>(tags);
    return map;
  }

  CardCacheCompanion toCompanion(bool nullToAbsent) {
    return CardCacheCompanion(
      factId: Value(factId),
      cardPath: Value(cardPath),
      timestamp: Value(timestamp),
      tags: Value(tags),
    );
  }

  factory CardCacheData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CardCacheData(
      factId: serializer.fromJson<String>(json['factId']),
      cardPath: serializer.fromJson<String>(json['cardPath']),
      timestamp: serializer.fromJson<int>(json['timestamp']),
      tags: serializer.fromJson<String>(json['tags']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'factId': serializer.toJson<String>(factId),
      'cardPath': serializer.toJson<String>(cardPath),
      'timestamp': serializer.toJson<int>(timestamp),
      'tags': serializer.toJson<String>(tags),
    };
  }

  CardCacheData copyWith(
          {String? factId, String? cardPath, int? timestamp, String? tags}) =>
      CardCacheData(
        factId: factId ?? this.factId,
        cardPath: cardPath ?? this.cardPath,
        timestamp: timestamp ?? this.timestamp,
        tags: tags ?? this.tags,
      );
  CardCacheData copyWithCompanion(CardCacheCompanion data) {
    return CardCacheData(
      factId: data.factId.present ? data.factId.value : this.factId,
      cardPath: data.cardPath.present ? data.cardPath.value : this.cardPath,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      tags: data.tags.present ? data.tags.value : this.tags,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CardCacheData(')
          ..write('factId: $factId, ')
          ..write('cardPath: $cardPath, ')
          ..write('timestamp: $timestamp, ')
          ..write('tags: $tags')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(factId, cardPath, timestamp, tags);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CardCacheData &&
          other.factId == this.factId &&
          other.cardPath == this.cardPath &&
          other.timestamp == this.timestamp &&
          other.tags == this.tags);
}

class CardCacheCompanion extends UpdateCompanion<CardCacheData> {
  final Value<String> factId;
  final Value<String> cardPath;
  final Value<int> timestamp;
  final Value<String> tags;
  final Value<int> rowid;
  const CardCacheCompanion({
    this.factId = const Value.absent(),
    this.cardPath = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.tags = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CardCacheCompanion.insert({
    required String factId,
    required String cardPath,
    required int timestamp,
    required String tags,
    this.rowid = const Value.absent(),
  })  : factId = Value(factId),
        cardPath = Value(cardPath),
        timestamp = Value(timestamp),
        tags = Value(tags);
  static Insertable<CardCacheData> custom({
    Expression<String>? factId,
    Expression<String>? cardPath,
    Expression<int>? timestamp,
    Expression<String>? tags,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (factId != null) 'fact_id': factId,
      if (cardPath != null) 'card_path': cardPath,
      if (timestamp != null) 'timestamp': timestamp,
      if (tags != null) 'tags': tags,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CardCacheCompanion copyWith(
      {Value<String>? factId,
      Value<String>? cardPath,
      Value<int>? timestamp,
      Value<String>? tags,
      Value<int>? rowid}) {
    return CardCacheCompanion(
      factId: factId ?? this.factId,
      cardPath: cardPath ?? this.cardPath,
      timestamp: timestamp ?? this.timestamp,
      tags: tags ?? this.tags,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (factId.present) {
      map['fact_id'] = Variable<String>(factId.value);
    }
    if (cardPath.present) {
      map['card_path'] = Variable<String>(cardPath.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<int>(timestamp.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CardCacheCompanion(')
          ..write('factId: $factId, ')
          ..write('cardPath: $cardPath, ')
          ..write('timestamp: $timestamp, ')
          ..write('tags: $tags, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SystemActionsTable extends SystemActions
    with TableInfo<$SystemActionsTable, SystemAction> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SystemActionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _actionTypeMeta =
      const VerificationMeta('actionType');
  @override
  late final GeneratedColumn<String> actionType = GeneratedColumn<String>(
      'action_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _actionDataMeta =
      const VerificationMeta('actionData');
  @override
  late final GeneratedColumn<String> actionData = GeneratedColumn<String>(
      'action_data', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _factIdMeta = const VerificationMeta('factId');
  @override
  late final GeneratedColumn<String> factId = GeneratedColumn<String>(
      'fact_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, actionType, actionData, status, factId, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'system_actions';
  @override
  VerificationContext validateIntegrity(Insertable<SystemAction> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('action_type')) {
      context.handle(
          _actionTypeMeta,
          actionType.isAcceptableOrUnknown(
              data['action_type']!, _actionTypeMeta));
    } else if (isInserting) {
      context.missing(_actionTypeMeta);
    }
    if (data.containsKey('action_data')) {
      context.handle(
          _actionDataMeta,
          actionData.isAcceptableOrUnknown(
              data['action_data']!, _actionDataMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('fact_id')) {
      context.handle(_factIdMeta,
          factId.isAcceptableOrUnknown(data['fact_id']!, _factIdMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SystemAction map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SystemAction(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      actionType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}action_type'])!,
      actionData: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}action_data']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      factId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}fact_id']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at']),
    );
  }

  @override
  $SystemActionsTable createAlias(String alias) {
    return $SystemActionsTable(attachedDatabase, alias);
  }
}

class SystemAction extends DataClass implements Insertable<SystemAction> {
  final String id;
  final String actionType;
  final String? actionData;
  final String status;
  final String? factId;
  final int? createdAt;
  final int? updatedAt;
  const SystemAction(
      {required this.id,
      required this.actionType,
      this.actionData,
      required this.status,
      this.factId,
      this.createdAt,
      this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['action_type'] = Variable<String>(actionType);
    if (!nullToAbsent || actionData != null) {
      map['action_data'] = Variable<String>(actionData);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || factId != null) {
      map['fact_id'] = Variable<String>(factId);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<int>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<int>(updatedAt);
    }
    return map;
  }

  SystemActionsCompanion toCompanion(bool nullToAbsent) {
    return SystemActionsCompanion(
      id: Value(id),
      actionType: Value(actionType),
      actionData: actionData == null && nullToAbsent
          ? const Value.absent()
          : Value(actionData),
      status: Value(status),
      factId:
          factId == null && nullToAbsent ? const Value.absent() : Value(factId),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory SystemAction.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SystemAction(
      id: serializer.fromJson<String>(json['id']),
      actionType: serializer.fromJson<String>(json['actionType']),
      actionData: serializer.fromJson<String?>(json['actionData']),
      status: serializer.fromJson<String>(json['status']),
      factId: serializer.fromJson<String?>(json['factId']),
      createdAt: serializer.fromJson<int?>(json['createdAt']),
      updatedAt: serializer.fromJson<int?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'actionType': serializer.toJson<String>(actionType),
      'actionData': serializer.toJson<String?>(actionData),
      'status': serializer.toJson<String>(status),
      'factId': serializer.toJson<String?>(factId),
      'createdAt': serializer.toJson<int?>(createdAt),
      'updatedAt': serializer.toJson<int?>(updatedAt),
    };
  }

  SystemAction copyWith(
          {String? id,
          String? actionType,
          Value<String?> actionData = const Value.absent(),
          String? status,
          Value<String?> factId = const Value.absent(),
          Value<int?> createdAt = const Value.absent(),
          Value<int?> updatedAt = const Value.absent()}) =>
      SystemAction(
        id: id ?? this.id,
        actionType: actionType ?? this.actionType,
        actionData: actionData.present ? actionData.value : this.actionData,
        status: status ?? this.status,
        factId: factId.present ? factId.value : this.factId,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
      );
  SystemAction copyWithCompanion(SystemActionsCompanion data) {
    return SystemAction(
      id: data.id.present ? data.id.value : this.id,
      actionType:
          data.actionType.present ? data.actionType.value : this.actionType,
      actionData:
          data.actionData.present ? data.actionData.value : this.actionData,
      status: data.status.present ? data.status.value : this.status,
      factId: data.factId.present ? data.factId.value : this.factId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SystemAction(')
          ..write('id: $id, ')
          ..write('actionType: $actionType, ')
          ..write('actionData: $actionData, ')
          ..write('status: $status, ')
          ..write('factId: $factId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, actionType, actionData, status, factId, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SystemAction &&
          other.id == this.id &&
          other.actionType == this.actionType &&
          other.actionData == this.actionData &&
          other.status == this.status &&
          other.factId == this.factId &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SystemActionsCompanion extends UpdateCompanion<SystemAction> {
  final Value<String> id;
  final Value<String> actionType;
  final Value<String?> actionData;
  final Value<String> status;
  final Value<String?> factId;
  final Value<int?> createdAt;
  final Value<int?> updatedAt;
  final Value<int> rowid;
  const SystemActionsCompanion({
    this.id = const Value.absent(),
    this.actionType = const Value.absent(),
    this.actionData = const Value.absent(),
    this.status = const Value.absent(),
    this.factId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SystemActionsCompanion.insert({
    required String id,
    required String actionType,
    this.actionData = const Value.absent(),
    required String status,
    this.factId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        actionType = Value(actionType),
        status = Value(status);
  static Insertable<SystemAction> custom({
    Expression<String>? id,
    Expression<String>? actionType,
    Expression<String>? actionData,
    Expression<String>? status,
    Expression<String>? factId,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (actionType != null) 'action_type': actionType,
      if (actionData != null) 'action_data': actionData,
      if (status != null) 'status': status,
      if (factId != null) 'fact_id': factId,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SystemActionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? actionType,
      Value<String?>? actionData,
      Value<String>? status,
      Value<String?>? factId,
      Value<int?>? createdAt,
      Value<int?>? updatedAt,
      Value<int>? rowid}) {
    return SystemActionsCompanion(
      id: id ?? this.id,
      actionType: actionType ?? this.actionType,
      actionData: actionData ?? this.actionData,
      status: status ?? this.status,
      factId: factId ?? this.factId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (actionType.present) {
      map['action_type'] = Variable<String>(actionType.value);
    }
    if (actionData.present) {
      map['action_data'] = Variable<String>(actionData.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (factId.present) {
      map['fact_id'] = Variable<String>(factId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SystemActionsCompanion(')
          ..write('id: $id, ')
          ..write('actionType: $actionType, ')
          ..write('actionData: $actionData, ')
          ..write('status: $status, ')
          ..write('factId: $factId, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ClarificationRequestsTable extends ClarificationRequests
    with TableInfo<$ClarificationRequestsTable, ClarificationRequest> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClarificationRequestsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _questionMeta =
      const VerificationMeta('question');
  @override
  late final GeneratedColumn<String> question = GeneratedColumn<String>(
      'question', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _responseTypeMeta =
      const VerificationMeta('responseType');
  @override
  late final GeneratedColumn<String> responseType = GeneratedColumn<String>(
      'response_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _optionsMeta =
      const VerificationMeta('options');
  @override
  late final GeneratedColumn<String> options = GeneratedColumn<String>(
      'options', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _answerDataMeta =
      const VerificationMeta('answerData');
  @override
  late final GeneratedColumn<String> answerData = GeneratedColumn<String>(
      'answer_data', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _entityTypeMeta =
      const VerificationMeta('entityType');
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
      'entity_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _entityLabelMeta =
      const VerificationMeta('entityLabel');
  @override
  late final GeneratedColumn<String> entityLabel = GeneratedColumn<String>(
      'entity_label', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _evidenceFactIdsMeta =
      const VerificationMeta('evidenceFactIds');
  @override
  late final GeneratedColumn<String> evidenceFactIds = GeneratedColumn<String>(
      'evidence_fact_ids', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
      'reason', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _impactMeta = const VerificationMeta('impact');
  @override
  late final GeneratedColumn<String> impact = GeneratedColumn<String>(
      'impact', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _confidenceMeta =
      const VerificationMeta('confidence');
  @override
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
      'confidence', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _proposedMemoryMeta =
      const VerificationMeta('proposedMemory');
  @override
  late final GeneratedColumn<String> proposedMemory = GeneratedColumn<String>(
      'proposed_memory', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _resolutionTargetMeta =
      const VerificationMeta('resolutionTarget');
  @override
  late final GeneratedColumn<String> resolutionTarget = GeneratedColumn<String>(
      'resolution_target', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _sourceAgentMeta =
      const VerificationMeta('sourceAgent');
  @override
  late final GeneratedColumn<String> sourceAgent = GeneratedColumn<String>(
      'source_agent', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _dedupeKeyMeta =
      const VerificationMeta('dedupeKey');
  @override
  late final GeneratedColumn<String> dedupeKey = GeneratedColumn<String>(
      'dedupe_key', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _factIdMeta = const VerificationMeta('factId');
  @override
  late final GeneratedColumn<String> factId = GeneratedColumn<String>(
      'fact_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _errorMeta = const VerificationMeta('error');
  @override
  late final GeneratedColumn<String> error = GeneratedColumn<String>(
      'error', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _answeredAtMeta =
      const VerificationMeta('answeredAt');
  @override
  late final GeneratedColumn<int> answeredAt = GeneratedColumn<int>(
      'answered_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _expiresAtMeta =
      const VerificationMeta('expiresAt');
  @override
  late final GeneratedColumn<int> expiresAt = GeneratedColumn<int>(
      'expires_at', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        question,
        responseType,
        options,
        status,
        answerData,
        entityType,
        entityLabel,
        evidenceFactIds,
        reason,
        impact,
        confidence,
        proposedMemory,
        resolutionTarget,
        sourceAgent,
        dedupeKey,
        factId,
        error,
        createdAt,
        updatedAt,
        answeredAt,
        expiresAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'clarification_requests';
  @override
  VerificationContext validateIntegrity(
      Insertable<ClarificationRequest> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('question')) {
      context.handle(_questionMeta,
          question.isAcceptableOrUnknown(data['question']!, _questionMeta));
    } else if (isInserting) {
      context.missing(_questionMeta);
    }
    if (data.containsKey('response_type')) {
      context.handle(
          _responseTypeMeta,
          responseType.isAcceptableOrUnknown(
              data['response_type']!, _responseTypeMeta));
    } else if (isInserting) {
      context.missing(_responseTypeMeta);
    }
    if (data.containsKey('options')) {
      context.handle(_optionsMeta,
          options.isAcceptableOrUnknown(data['options']!, _optionsMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('answer_data')) {
      context.handle(
          _answerDataMeta,
          answerData.isAcceptableOrUnknown(
              data['answer_data']!, _answerDataMeta));
    }
    if (data.containsKey('entity_type')) {
      context.handle(
          _entityTypeMeta,
          entityType.isAcceptableOrUnknown(
              data['entity_type']!, _entityTypeMeta));
    }
    if (data.containsKey('entity_label')) {
      context.handle(
          _entityLabelMeta,
          entityLabel.isAcceptableOrUnknown(
              data['entity_label']!, _entityLabelMeta));
    }
    if (data.containsKey('evidence_fact_ids')) {
      context.handle(
          _evidenceFactIdsMeta,
          evidenceFactIds.isAcceptableOrUnknown(
              data['evidence_fact_ids']!, _evidenceFactIdsMeta));
    }
    if (data.containsKey('reason')) {
      context.handle(_reasonMeta,
          reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta));
    }
    if (data.containsKey('impact')) {
      context.handle(_impactMeta,
          impact.isAcceptableOrUnknown(data['impact']!, _impactMeta));
    }
    if (data.containsKey('confidence')) {
      context.handle(
          _confidenceMeta,
          confidence.isAcceptableOrUnknown(
              data['confidence']!, _confidenceMeta));
    }
    if (data.containsKey('proposed_memory')) {
      context.handle(
          _proposedMemoryMeta,
          proposedMemory.isAcceptableOrUnknown(
              data['proposed_memory']!, _proposedMemoryMeta));
    }
    if (data.containsKey('resolution_target')) {
      context.handle(
          _resolutionTargetMeta,
          resolutionTarget.isAcceptableOrUnknown(
              data['resolution_target']!, _resolutionTargetMeta));
    }
    if (data.containsKey('source_agent')) {
      context.handle(
          _sourceAgentMeta,
          sourceAgent.isAcceptableOrUnknown(
              data['source_agent']!, _sourceAgentMeta));
    }
    if (data.containsKey('dedupe_key')) {
      context.handle(_dedupeKeyMeta,
          dedupeKey.isAcceptableOrUnknown(data['dedupe_key']!, _dedupeKeyMeta));
    }
    if (data.containsKey('fact_id')) {
      context.handle(_factIdMeta,
          factId.isAcceptableOrUnknown(data['fact_id']!, _factIdMeta));
    }
    if (data.containsKey('error')) {
      context.handle(
          _errorMeta, error.isAcceptableOrUnknown(data['error']!, _errorMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    if (data.containsKey('answered_at')) {
      context.handle(
          _answeredAtMeta,
          answeredAt.isAcceptableOrUnknown(
              data['answered_at']!, _answeredAtMeta));
    }
    if (data.containsKey('expires_at')) {
      context.handle(_expiresAtMeta,
          expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ClarificationRequest map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ClarificationRequest(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      question: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}question'])!,
      responseType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}response_type'])!,
      options: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}options']),
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      answerData: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}answer_data']),
      entityType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_type']),
      entityLabel: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity_label']),
      evidenceFactIds: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}evidence_fact_ids']),
      reason: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}reason']),
      impact: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}impact']),
      confidence: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}confidence']),
      proposedMemory: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}proposed_memory']),
      resolutionTarget: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}resolution_target']),
      sourceAgent: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}source_agent']),
      dedupeKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}dedupe_key']),
      factId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}fact_id']),
      error: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}error']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at']),
      answeredAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}answered_at']),
      expiresAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}expires_at']),
    );
  }

  @override
  $ClarificationRequestsTable createAlias(String alias) {
    return $ClarificationRequestsTable(attachedDatabase, alias);
  }
}

class ClarificationRequest extends DataClass
    implements Insertable<ClarificationRequest> {
  final String id;
  final String question;
  final String responseType;
  final String? options;
  final String status;
  final String? answerData;
  final String? entityType;
  final String? entityLabel;
  final String? evidenceFactIds;
  final String? reason;
  final String? impact;
  final double? confidence;
  final String? proposedMemory;
  final String? resolutionTarget;
  final String? sourceAgent;
  final String? dedupeKey;
  final String? factId;
  final String? error;
  final int? createdAt;
  final int? updatedAt;
  final int? answeredAt;
  final int? expiresAt;
  const ClarificationRequest(
      {required this.id,
      required this.question,
      required this.responseType,
      this.options,
      required this.status,
      this.answerData,
      this.entityType,
      this.entityLabel,
      this.evidenceFactIds,
      this.reason,
      this.impact,
      this.confidence,
      this.proposedMemory,
      this.resolutionTarget,
      this.sourceAgent,
      this.dedupeKey,
      this.factId,
      this.error,
      this.createdAt,
      this.updatedAt,
      this.answeredAt,
      this.expiresAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['question'] = Variable<String>(question);
    map['response_type'] = Variable<String>(responseType);
    if (!nullToAbsent || options != null) {
      map['options'] = Variable<String>(options);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || answerData != null) {
      map['answer_data'] = Variable<String>(answerData);
    }
    if (!nullToAbsent || entityType != null) {
      map['entity_type'] = Variable<String>(entityType);
    }
    if (!nullToAbsent || entityLabel != null) {
      map['entity_label'] = Variable<String>(entityLabel);
    }
    if (!nullToAbsent || evidenceFactIds != null) {
      map['evidence_fact_ids'] = Variable<String>(evidenceFactIds);
    }
    if (!nullToAbsent || reason != null) {
      map['reason'] = Variable<String>(reason);
    }
    if (!nullToAbsent || impact != null) {
      map['impact'] = Variable<String>(impact);
    }
    if (!nullToAbsent || confidence != null) {
      map['confidence'] = Variable<double>(confidence);
    }
    if (!nullToAbsent || proposedMemory != null) {
      map['proposed_memory'] = Variable<String>(proposedMemory);
    }
    if (!nullToAbsent || resolutionTarget != null) {
      map['resolution_target'] = Variable<String>(resolutionTarget);
    }
    if (!nullToAbsent || sourceAgent != null) {
      map['source_agent'] = Variable<String>(sourceAgent);
    }
    if (!nullToAbsent || dedupeKey != null) {
      map['dedupe_key'] = Variable<String>(dedupeKey);
    }
    if (!nullToAbsent || factId != null) {
      map['fact_id'] = Variable<String>(factId);
    }
    if (!nullToAbsent || error != null) {
      map['error'] = Variable<String>(error);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<int>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<int>(updatedAt);
    }
    if (!nullToAbsent || answeredAt != null) {
      map['answered_at'] = Variable<int>(answeredAt);
    }
    if (!nullToAbsent || expiresAt != null) {
      map['expires_at'] = Variable<int>(expiresAt);
    }
    return map;
  }

  ClarificationRequestsCompanion toCompanion(bool nullToAbsent) {
    return ClarificationRequestsCompanion(
      id: Value(id),
      question: Value(question),
      responseType: Value(responseType),
      options: options == null && nullToAbsent
          ? const Value.absent()
          : Value(options),
      status: Value(status),
      answerData: answerData == null && nullToAbsent
          ? const Value.absent()
          : Value(answerData),
      entityType: entityType == null && nullToAbsent
          ? const Value.absent()
          : Value(entityType),
      entityLabel: entityLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(entityLabel),
      evidenceFactIds: evidenceFactIds == null && nullToAbsent
          ? const Value.absent()
          : Value(evidenceFactIds),
      reason:
          reason == null && nullToAbsent ? const Value.absent() : Value(reason),
      impact:
          impact == null && nullToAbsent ? const Value.absent() : Value(impact),
      confidence: confidence == null && nullToAbsent
          ? const Value.absent()
          : Value(confidence),
      proposedMemory: proposedMemory == null && nullToAbsent
          ? const Value.absent()
          : Value(proposedMemory),
      resolutionTarget: resolutionTarget == null && nullToAbsent
          ? const Value.absent()
          : Value(resolutionTarget),
      sourceAgent: sourceAgent == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceAgent),
      dedupeKey: dedupeKey == null && nullToAbsent
          ? const Value.absent()
          : Value(dedupeKey),
      factId:
          factId == null && nullToAbsent ? const Value.absent() : Value(factId),
      error:
          error == null && nullToAbsent ? const Value.absent() : Value(error),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
      answeredAt: answeredAt == null && nullToAbsent
          ? const Value.absent()
          : Value(answeredAt),
      expiresAt: expiresAt == null && nullToAbsent
          ? const Value.absent()
          : Value(expiresAt),
    );
  }

  factory ClarificationRequest.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ClarificationRequest(
      id: serializer.fromJson<String>(json['id']),
      question: serializer.fromJson<String>(json['question']),
      responseType: serializer.fromJson<String>(json['responseType']),
      options: serializer.fromJson<String?>(json['options']),
      status: serializer.fromJson<String>(json['status']),
      answerData: serializer.fromJson<String?>(json['answerData']),
      entityType: serializer.fromJson<String?>(json['entityType']),
      entityLabel: serializer.fromJson<String?>(json['entityLabel']),
      evidenceFactIds: serializer.fromJson<String?>(json['evidenceFactIds']),
      reason: serializer.fromJson<String?>(json['reason']),
      impact: serializer.fromJson<String?>(json['impact']),
      confidence: serializer.fromJson<double?>(json['confidence']),
      proposedMemory: serializer.fromJson<String?>(json['proposedMemory']),
      resolutionTarget: serializer.fromJson<String?>(json['resolutionTarget']),
      sourceAgent: serializer.fromJson<String?>(json['sourceAgent']),
      dedupeKey: serializer.fromJson<String?>(json['dedupeKey']),
      factId: serializer.fromJson<String?>(json['factId']),
      error: serializer.fromJson<String?>(json['error']),
      createdAt: serializer.fromJson<int?>(json['createdAt']),
      updatedAt: serializer.fromJson<int?>(json['updatedAt']),
      answeredAt: serializer.fromJson<int?>(json['answeredAt']),
      expiresAt: serializer.fromJson<int?>(json['expiresAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'question': serializer.toJson<String>(question),
      'responseType': serializer.toJson<String>(responseType),
      'options': serializer.toJson<String?>(options),
      'status': serializer.toJson<String>(status),
      'answerData': serializer.toJson<String?>(answerData),
      'entityType': serializer.toJson<String?>(entityType),
      'entityLabel': serializer.toJson<String?>(entityLabel),
      'evidenceFactIds': serializer.toJson<String?>(evidenceFactIds),
      'reason': serializer.toJson<String?>(reason),
      'impact': serializer.toJson<String?>(impact),
      'confidence': serializer.toJson<double?>(confidence),
      'proposedMemory': serializer.toJson<String?>(proposedMemory),
      'resolutionTarget': serializer.toJson<String?>(resolutionTarget),
      'sourceAgent': serializer.toJson<String?>(sourceAgent),
      'dedupeKey': serializer.toJson<String?>(dedupeKey),
      'factId': serializer.toJson<String?>(factId),
      'error': serializer.toJson<String?>(error),
      'createdAt': serializer.toJson<int?>(createdAt),
      'updatedAt': serializer.toJson<int?>(updatedAt),
      'answeredAt': serializer.toJson<int?>(answeredAt),
      'expiresAt': serializer.toJson<int?>(expiresAt),
    };
  }

  ClarificationRequest copyWith(
          {String? id,
          String? question,
          String? responseType,
          Value<String?> options = const Value.absent(),
          String? status,
          Value<String?> answerData = const Value.absent(),
          Value<String?> entityType = const Value.absent(),
          Value<String?> entityLabel = const Value.absent(),
          Value<String?> evidenceFactIds = const Value.absent(),
          Value<String?> reason = const Value.absent(),
          Value<String?> impact = const Value.absent(),
          Value<double?> confidence = const Value.absent(),
          Value<String?> proposedMemory = const Value.absent(),
          Value<String?> resolutionTarget = const Value.absent(),
          Value<String?> sourceAgent = const Value.absent(),
          Value<String?> dedupeKey = const Value.absent(),
          Value<String?> factId = const Value.absent(),
          Value<String?> error = const Value.absent(),
          Value<int?> createdAt = const Value.absent(),
          Value<int?> updatedAt = const Value.absent(),
          Value<int?> answeredAt = const Value.absent(),
          Value<int?> expiresAt = const Value.absent()}) =>
      ClarificationRequest(
        id: id ?? this.id,
        question: question ?? this.question,
        responseType: responseType ?? this.responseType,
        options: options.present ? options.value : this.options,
        status: status ?? this.status,
        answerData: answerData.present ? answerData.value : this.answerData,
        entityType: entityType.present ? entityType.value : this.entityType,
        entityLabel: entityLabel.present ? entityLabel.value : this.entityLabel,
        evidenceFactIds: evidenceFactIds.present
            ? evidenceFactIds.value
            : this.evidenceFactIds,
        reason: reason.present ? reason.value : this.reason,
        impact: impact.present ? impact.value : this.impact,
        confidence: confidence.present ? confidence.value : this.confidence,
        proposedMemory:
            proposedMemory.present ? proposedMemory.value : this.proposedMemory,
        resolutionTarget: resolutionTarget.present
            ? resolutionTarget.value
            : this.resolutionTarget,
        sourceAgent: sourceAgent.present ? sourceAgent.value : this.sourceAgent,
        dedupeKey: dedupeKey.present ? dedupeKey.value : this.dedupeKey,
        factId: factId.present ? factId.value : this.factId,
        error: error.present ? error.value : this.error,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
        answeredAt: answeredAt.present ? answeredAt.value : this.answeredAt,
        expiresAt: expiresAt.present ? expiresAt.value : this.expiresAt,
      );
  ClarificationRequest copyWithCompanion(ClarificationRequestsCompanion data) {
    return ClarificationRequest(
      id: data.id.present ? data.id.value : this.id,
      question: data.question.present ? data.question.value : this.question,
      responseType: data.responseType.present
          ? data.responseType.value
          : this.responseType,
      options: data.options.present ? data.options.value : this.options,
      status: data.status.present ? data.status.value : this.status,
      answerData:
          data.answerData.present ? data.answerData.value : this.answerData,
      entityType:
          data.entityType.present ? data.entityType.value : this.entityType,
      entityLabel:
          data.entityLabel.present ? data.entityLabel.value : this.entityLabel,
      evidenceFactIds: data.evidenceFactIds.present
          ? data.evidenceFactIds.value
          : this.evidenceFactIds,
      reason: data.reason.present ? data.reason.value : this.reason,
      impact: data.impact.present ? data.impact.value : this.impact,
      confidence:
          data.confidence.present ? data.confidence.value : this.confidence,
      proposedMemory: data.proposedMemory.present
          ? data.proposedMemory.value
          : this.proposedMemory,
      resolutionTarget: data.resolutionTarget.present
          ? data.resolutionTarget.value
          : this.resolutionTarget,
      sourceAgent:
          data.sourceAgent.present ? data.sourceAgent.value : this.sourceAgent,
      dedupeKey: data.dedupeKey.present ? data.dedupeKey.value : this.dedupeKey,
      factId: data.factId.present ? data.factId.value : this.factId,
      error: data.error.present ? data.error.value : this.error,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      answeredAt:
          data.answeredAt.present ? data.answeredAt.value : this.answeredAt,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ClarificationRequest(')
          ..write('id: $id, ')
          ..write('question: $question, ')
          ..write('responseType: $responseType, ')
          ..write('options: $options, ')
          ..write('status: $status, ')
          ..write('answerData: $answerData, ')
          ..write('entityType: $entityType, ')
          ..write('entityLabel: $entityLabel, ')
          ..write('evidenceFactIds: $evidenceFactIds, ')
          ..write('reason: $reason, ')
          ..write('impact: $impact, ')
          ..write('confidence: $confidence, ')
          ..write('proposedMemory: $proposedMemory, ')
          ..write('resolutionTarget: $resolutionTarget, ')
          ..write('sourceAgent: $sourceAgent, ')
          ..write('dedupeKey: $dedupeKey, ')
          ..write('factId: $factId, ')
          ..write('error: $error, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('answeredAt: $answeredAt, ')
          ..write('expiresAt: $expiresAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
        id,
        question,
        responseType,
        options,
        status,
        answerData,
        entityType,
        entityLabel,
        evidenceFactIds,
        reason,
        impact,
        confidence,
        proposedMemory,
        resolutionTarget,
        sourceAgent,
        dedupeKey,
        factId,
        error,
        createdAt,
        updatedAt,
        answeredAt,
        expiresAt
      ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClarificationRequest &&
          other.id == this.id &&
          other.question == this.question &&
          other.responseType == this.responseType &&
          other.options == this.options &&
          other.status == this.status &&
          other.answerData == this.answerData &&
          other.entityType == this.entityType &&
          other.entityLabel == this.entityLabel &&
          other.evidenceFactIds == this.evidenceFactIds &&
          other.reason == this.reason &&
          other.impact == this.impact &&
          other.confidence == this.confidence &&
          other.proposedMemory == this.proposedMemory &&
          other.resolutionTarget == this.resolutionTarget &&
          other.sourceAgent == this.sourceAgent &&
          other.dedupeKey == this.dedupeKey &&
          other.factId == this.factId &&
          other.error == this.error &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.answeredAt == this.answeredAt &&
          other.expiresAt == this.expiresAt);
}

class ClarificationRequestsCompanion
    extends UpdateCompanion<ClarificationRequest> {
  final Value<String> id;
  final Value<String> question;
  final Value<String> responseType;
  final Value<String?> options;
  final Value<String> status;
  final Value<String?> answerData;
  final Value<String?> entityType;
  final Value<String?> entityLabel;
  final Value<String?> evidenceFactIds;
  final Value<String?> reason;
  final Value<String?> impact;
  final Value<double?> confidence;
  final Value<String?> proposedMemory;
  final Value<String?> resolutionTarget;
  final Value<String?> sourceAgent;
  final Value<String?> dedupeKey;
  final Value<String?> factId;
  final Value<String?> error;
  final Value<int?> createdAt;
  final Value<int?> updatedAt;
  final Value<int?> answeredAt;
  final Value<int?> expiresAt;
  final Value<int> rowid;
  const ClarificationRequestsCompanion({
    this.id = const Value.absent(),
    this.question = const Value.absent(),
    this.responseType = const Value.absent(),
    this.options = const Value.absent(),
    this.status = const Value.absent(),
    this.answerData = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityLabel = const Value.absent(),
    this.evidenceFactIds = const Value.absent(),
    this.reason = const Value.absent(),
    this.impact = const Value.absent(),
    this.confidence = const Value.absent(),
    this.proposedMemory = const Value.absent(),
    this.resolutionTarget = const Value.absent(),
    this.sourceAgent = const Value.absent(),
    this.dedupeKey = const Value.absent(),
    this.factId = const Value.absent(),
    this.error = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.answeredAt = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ClarificationRequestsCompanion.insert({
    required String id,
    required String question,
    required String responseType,
    this.options = const Value.absent(),
    required String status,
    this.answerData = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityLabel = const Value.absent(),
    this.evidenceFactIds = const Value.absent(),
    this.reason = const Value.absent(),
    this.impact = const Value.absent(),
    this.confidence = const Value.absent(),
    this.proposedMemory = const Value.absent(),
    this.resolutionTarget = const Value.absent(),
    this.sourceAgent = const Value.absent(),
    this.dedupeKey = const Value.absent(),
    this.factId = const Value.absent(),
    this.error = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.answeredAt = const Value.absent(),
    this.expiresAt = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        question = Value(question),
        responseType = Value(responseType),
        status = Value(status);
  static Insertable<ClarificationRequest> custom({
    Expression<String>? id,
    Expression<String>? question,
    Expression<String>? responseType,
    Expression<String>? options,
    Expression<String>? status,
    Expression<String>? answerData,
    Expression<String>? entityType,
    Expression<String>? entityLabel,
    Expression<String>? evidenceFactIds,
    Expression<String>? reason,
    Expression<String>? impact,
    Expression<double>? confidence,
    Expression<String>? proposedMemory,
    Expression<String>? resolutionTarget,
    Expression<String>? sourceAgent,
    Expression<String>? dedupeKey,
    Expression<String>? factId,
    Expression<String>? error,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? answeredAt,
    Expression<int>? expiresAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (question != null) 'question': question,
      if (responseType != null) 'response_type': responseType,
      if (options != null) 'options': options,
      if (status != null) 'status': status,
      if (answerData != null) 'answer_data': answerData,
      if (entityType != null) 'entity_type': entityType,
      if (entityLabel != null) 'entity_label': entityLabel,
      if (evidenceFactIds != null) 'evidence_fact_ids': evidenceFactIds,
      if (reason != null) 'reason': reason,
      if (impact != null) 'impact': impact,
      if (confidence != null) 'confidence': confidence,
      if (proposedMemory != null) 'proposed_memory': proposedMemory,
      if (resolutionTarget != null) 'resolution_target': resolutionTarget,
      if (sourceAgent != null) 'source_agent': sourceAgent,
      if (dedupeKey != null) 'dedupe_key': dedupeKey,
      if (factId != null) 'fact_id': factId,
      if (error != null) 'error': error,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (answeredAt != null) 'answered_at': answeredAt,
      if (expiresAt != null) 'expires_at': expiresAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ClarificationRequestsCompanion copyWith(
      {Value<String>? id,
      Value<String>? question,
      Value<String>? responseType,
      Value<String?>? options,
      Value<String>? status,
      Value<String?>? answerData,
      Value<String?>? entityType,
      Value<String?>? entityLabel,
      Value<String?>? evidenceFactIds,
      Value<String?>? reason,
      Value<String?>? impact,
      Value<double?>? confidence,
      Value<String?>? proposedMemory,
      Value<String?>? resolutionTarget,
      Value<String?>? sourceAgent,
      Value<String?>? dedupeKey,
      Value<String?>? factId,
      Value<String?>? error,
      Value<int?>? createdAt,
      Value<int?>? updatedAt,
      Value<int?>? answeredAt,
      Value<int?>? expiresAt,
      Value<int>? rowid}) {
    return ClarificationRequestsCompanion(
      id: id ?? this.id,
      question: question ?? this.question,
      responseType: responseType ?? this.responseType,
      options: options ?? this.options,
      status: status ?? this.status,
      answerData: answerData ?? this.answerData,
      entityType: entityType ?? this.entityType,
      entityLabel: entityLabel ?? this.entityLabel,
      evidenceFactIds: evidenceFactIds ?? this.evidenceFactIds,
      reason: reason ?? this.reason,
      impact: impact ?? this.impact,
      confidence: confidence ?? this.confidence,
      proposedMemory: proposedMemory ?? this.proposedMemory,
      resolutionTarget: resolutionTarget ?? this.resolutionTarget,
      sourceAgent: sourceAgent ?? this.sourceAgent,
      dedupeKey: dedupeKey ?? this.dedupeKey,
      factId: factId ?? this.factId,
      error: error ?? this.error,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      answeredAt: answeredAt ?? this.answeredAt,
      expiresAt: expiresAt ?? this.expiresAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (question.present) {
      map['question'] = Variable<String>(question.value);
    }
    if (responseType.present) {
      map['response_type'] = Variable<String>(responseType.value);
    }
    if (options.present) {
      map['options'] = Variable<String>(options.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (answerData.present) {
      map['answer_data'] = Variable<String>(answerData.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityLabel.present) {
      map['entity_label'] = Variable<String>(entityLabel.value);
    }
    if (evidenceFactIds.present) {
      map['evidence_fact_ids'] = Variable<String>(evidenceFactIds.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (impact.present) {
      map['impact'] = Variable<String>(impact.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (proposedMemory.present) {
      map['proposed_memory'] = Variable<String>(proposedMemory.value);
    }
    if (resolutionTarget.present) {
      map['resolution_target'] = Variable<String>(resolutionTarget.value);
    }
    if (sourceAgent.present) {
      map['source_agent'] = Variable<String>(sourceAgent.value);
    }
    if (dedupeKey.present) {
      map['dedupe_key'] = Variable<String>(dedupeKey.value);
    }
    if (factId.present) {
      map['fact_id'] = Variable<String>(factId.value);
    }
    if (error.present) {
      map['error'] = Variable<String>(error.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (answeredAt.present) {
      map['answered_at'] = Variable<int>(answeredAt.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<int>(expiresAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClarificationRequestsCompanion(')
          ..write('id: $id, ')
          ..write('question: $question, ')
          ..write('responseType: $responseType, ')
          ..write('options: $options, ')
          ..write('status: $status, ')
          ..write('answerData: $answerData, ')
          ..write('entityType: $entityType, ')
          ..write('entityLabel: $entityLabel, ')
          ..write('evidenceFactIds: $evidenceFactIds, ')
          ..write('reason: $reason, ')
          ..write('impact: $impact, ')
          ..write('confidence: $confidence, ')
          ..write('proposedMemory: $proposedMemory, ')
          ..write('resolutionTarget: $resolutionTarget, ')
          ..write('sourceAgent: $sourceAgent, ')
          ..write('dedupeKey: $dedupeKey, ')
          ..write('factId: $factId, ')
          ..write('error: $error, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('answeredAt: $answeredAt, ')
          ..write('expiresAt: $expiresAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PersonaChatMessagesTable extends PersonaChatMessages
    with TableInfo<$PersonaChatMessagesTable, PersonaChatMessage> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PersonaChatMessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _characterIdMeta =
      const VerificationMeta('characterId');
  @override
  late final GeneratedColumn<String> characterId = GeneratedColumn<String>(
      'character_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isFromCharacterMeta =
      const VerificationMeta('isFromCharacter');
  @override
  late final GeneratedColumn<bool> isFromCharacter = GeneratedColumn<bool>(
      'is_from_character', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_from_character" IN (0, 1))'));
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _factIdMeta = const VerificationMeta('factId');
  @override
  late final GeneratedColumn<String> factId = GeneratedColumn<String>(
      'fact_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _isReadMeta = const VerificationMeta('isRead');
  @override
  late final GeneratedColumn<bool> isRead = GeneratedColumn<bool>(
      'is_read', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_read" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _timestampMeta =
      const VerificationMeta('timestamp');
  @override
  late final GeneratedColumn<DateTime> timestamp = GeneratedColumn<DateTime>(
      'timestamp', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _messageTypeMeta =
      const VerificationMeta('messageType');
  @override
  late final GeneratedColumn<String> messageType = GeneratedColumn<String>(
      'message_type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('chat'));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        characterId,
        isFromCharacter,
        content,
        factId,
        isRead,
        timestamp,
        messageType
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'persona_chat_messages';
  @override
  VerificationContext validateIntegrity(Insertable<PersonaChatMessage> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('character_id')) {
      context.handle(
          _characterIdMeta,
          characterId.isAcceptableOrUnknown(
              data['character_id']!, _characterIdMeta));
    } else if (isInserting) {
      context.missing(_characterIdMeta);
    }
    if (data.containsKey('is_from_character')) {
      context.handle(
          _isFromCharacterMeta,
          isFromCharacter.isAcceptableOrUnknown(
              data['is_from_character']!, _isFromCharacterMeta));
    } else if (isInserting) {
      context.missing(_isFromCharacterMeta);
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('fact_id')) {
      context.handle(_factIdMeta,
          factId.isAcceptableOrUnknown(data['fact_id']!, _factIdMeta));
    }
    if (data.containsKey('is_read')) {
      context.handle(_isReadMeta,
          isRead.isAcceptableOrUnknown(data['is_read']!, _isReadMeta));
    }
    if (data.containsKey('timestamp')) {
      context.handle(_timestampMeta,
          timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta));
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('message_type')) {
      context.handle(
          _messageTypeMeta,
          messageType.isAcceptableOrUnknown(
              data['message_type']!, _messageTypeMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PersonaChatMessage map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PersonaChatMessage(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      characterId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}character_id'])!,
      isFromCharacter: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}is_from_character'])!,
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content'])!,
      factId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}fact_id']),
      isRead: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_read'])!,
      timestamp: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}timestamp'])!,
      messageType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}message_type'])!,
    );
  }

  @override
  $PersonaChatMessagesTable createAlias(String alias) {
    return $PersonaChatMessagesTable(attachedDatabase, alias);
  }
}

class PersonaChatMessage extends DataClass
    implements Insertable<PersonaChatMessage> {
  final int id;
  final String characterId;
  final bool isFromCharacter;
  final String content;
  final String? factId;
  final bool isRead;
  final DateTime timestamp;

  /// Message type: 'chat' (default) or 'action' (narrative/action description).
  final String messageType;
  const PersonaChatMessage(
      {required this.id,
      required this.characterId,
      required this.isFromCharacter,
      required this.content,
      this.factId,
      required this.isRead,
      required this.timestamp,
      required this.messageType});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['character_id'] = Variable<String>(characterId);
    map['is_from_character'] = Variable<bool>(isFromCharacter);
    map['content'] = Variable<String>(content);
    if (!nullToAbsent || factId != null) {
      map['fact_id'] = Variable<String>(factId);
    }
    map['is_read'] = Variable<bool>(isRead);
    map['timestamp'] = Variable<DateTime>(timestamp);
    map['message_type'] = Variable<String>(messageType);
    return map;
  }

  PersonaChatMessagesCompanion toCompanion(bool nullToAbsent) {
    return PersonaChatMessagesCompanion(
      id: Value(id),
      characterId: Value(characterId),
      isFromCharacter: Value(isFromCharacter),
      content: Value(content),
      factId:
          factId == null && nullToAbsent ? const Value.absent() : Value(factId),
      isRead: Value(isRead),
      timestamp: Value(timestamp),
      messageType: Value(messageType),
    );
  }

  factory PersonaChatMessage.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PersonaChatMessage(
      id: serializer.fromJson<int>(json['id']),
      characterId: serializer.fromJson<String>(json['characterId']),
      isFromCharacter: serializer.fromJson<bool>(json['isFromCharacter']),
      content: serializer.fromJson<String>(json['content']),
      factId: serializer.fromJson<String?>(json['factId']),
      isRead: serializer.fromJson<bool>(json['isRead']),
      timestamp: serializer.fromJson<DateTime>(json['timestamp']),
      messageType: serializer.fromJson<String>(json['messageType']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'characterId': serializer.toJson<String>(characterId),
      'isFromCharacter': serializer.toJson<bool>(isFromCharacter),
      'content': serializer.toJson<String>(content),
      'factId': serializer.toJson<String?>(factId),
      'isRead': serializer.toJson<bool>(isRead),
      'timestamp': serializer.toJson<DateTime>(timestamp),
      'messageType': serializer.toJson<String>(messageType),
    };
  }

  PersonaChatMessage copyWith(
          {int? id,
          String? characterId,
          bool? isFromCharacter,
          String? content,
          Value<String?> factId = const Value.absent(),
          bool? isRead,
          DateTime? timestamp,
          String? messageType}) =>
      PersonaChatMessage(
        id: id ?? this.id,
        characterId: characterId ?? this.characterId,
        isFromCharacter: isFromCharacter ?? this.isFromCharacter,
        content: content ?? this.content,
        factId: factId.present ? factId.value : this.factId,
        isRead: isRead ?? this.isRead,
        timestamp: timestamp ?? this.timestamp,
        messageType: messageType ?? this.messageType,
      );
  PersonaChatMessage copyWithCompanion(PersonaChatMessagesCompanion data) {
    return PersonaChatMessage(
      id: data.id.present ? data.id.value : this.id,
      characterId:
          data.characterId.present ? data.characterId.value : this.characterId,
      isFromCharacter: data.isFromCharacter.present
          ? data.isFromCharacter.value
          : this.isFromCharacter,
      content: data.content.present ? data.content.value : this.content,
      factId: data.factId.present ? data.factId.value : this.factId,
      isRead: data.isRead.present ? data.isRead.value : this.isRead,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      messageType:
          data.messageType.present ? data.messageType.value : this.messageType,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PersonaChatMessage(')
          ..write('id: $id, ')
          ..write('characterId: $characterId, ')
          ..write('isFromCharacter: $isFromCharacter, ')
          ..write('content: $content, ')
          ..write('factId: $factId, ')
          ..write('isRead: $isRead, ')
          ..write('timestamp: $timestamp, ')
          ..write('messageType: $messageType')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, characterId, isFromCharacter, content,
      factId, isRead, timestamp, messageType);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PersonaChatMessage &&
          other.id == this.id &&
          other.characterId == this.characterId &&
          other.isFromCharacter == this.isFromCharacter &&
          other.content == this.content &&
          other.factId == this.factId &&
          other.isRead == this.isRead &&
          other.timestamp == this.timestamp &&
          other.messageType == this.messageType);
}

class PersonaChatMessagesCompanion extends UpdateCompanion<PersonaChatMessage> {
  final Value<int> id;
  final Value<String> characterId;
  final Value<bool> isFromCharacter;
  final Value<String> content;
  final Value<String?> factId;
  final Value<bool> isRead;
  final Value<DateTime> timestamp;
  final Value<String> messageType;
  const PersonaChatMessagesCompanion({
    this.id = const Value.absent(),
    this.characterId = const Value.absent(),
    this.isFromCharacter = const Value.absent(),
    this.content = const Value.absent(),
    this.factId = const Value.absent(),
    this.isRead = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.messageType = const Value.absent(),
  });
  PersonaChatMessagesCompanion.insert({
    this.id = const Value.absent(),
    required String characterId,
    required bool isFromCharacter,
    required String content,
    this.factId = const Value.absent(),
    this.isRead = const Value.absent(),
    required DateTime timestamp,
    this.messageType = const Value.absent(),
  })  : characterId = Value(characterId),
        isFromCharacter = Value(isFromCharacter),
        content = Value(content),
        timestamp = Value(timestamp);
  static Insertable<PersonaChatMessage> custom({
    Expression<int>? id,
    Expression<String>? characterId,
    Expression<bool>? isFromCharacter,
    Expression<String>? content,
    Expression<String>? factId,
    Expression<bool>? isRead,
    Expression<DateTime>? timestamp,
    Expression<String>? messageType,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (characterId != null) 'character_id': characterId,
      if (isFromCharacter != null) 'is_from_character': isFromCharacter,
      if (content != null) 'content': content,
      if (factId != null) 'fact_id': factId,
      if (isRead != null) 'is_read': isRead,
      if (timestamp != null) 'timestamp': timestamp,
      if (messageType != null) 'message_type': messageType,
    });
  }

  PersonaChatMessagesCompanion copyWith(
      {Value<int>? id,
      Value<String>? characterId,
      Value<bool>? isFromCharacter,
      Value<String>? content,
      Value<String?>? factId,
      Value<bool>? isRead,
      Value<DateTime>? timestamp,
      Value<String>? messageType}) {
    return PersonaChatMessagesCompanion(
      id: id ?? this.id,
      characterId: characterId ?? this.characterId,
      isFromCharacter: isFromCharacter ?? this.isFromCharacter,
      content: content ?? this.content,
      factId: factId ?? this.factId,
      isRead: isRead ?? this.isRead,
      timestamp: timestamp ?? this.timestamp,
      messageType: messageType ?? this.messageType,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (characterId.present) {
      map['character_id'] = Variable<String>(characterId.value);
    }
    if (isFromCharacter.present) {
      map['is_from_character'] = Variable<bool>(isFromCharacter.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (factId.present) {
      map['fact_id'] = Variable<String>(factId.value);
    }
    if (isRead.present) {
      map['is_read'] = Variable<bool>(isRead.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<DateTime>(timestamp.value);
    }
    if (messageType.present) {
      map['message_type'] = Variable<String>(messageType.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PersonaChatMessagesCompanion(')
          ..write('id: $id, ')
          ..write('characterId: $characterId, ')
          ..write('isFromCharacter: $isFromCharacter, ')
          ..write('content: $content, ')
          ..write('factId: $factId, ')
          ..write('isRead: $isRead, ')
          ..write('timestamp: $timestamp, ')
          ..write('messageType: $messageType')
          ..write(')'))
        .toString();
  }
}

class $UserNotificationsTable extends UserNotifications
    with TableInfo<$UserNotificationsTable, UserNotification> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserNotificationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _notificationTypeMeta =
      const VerificationMeta('notificationType');
  @override
  late final GeneratedColumn<String> notificationType = GeneratedColumn<String>(
      'notification_type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _subjectKeyMeta =
      const VerificationMeta('subjectKey');
  @override
  late final GeneratedColumn<String> subjectKey = GeneratedColumn<String>(
      'subject_key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _payloadMeta =
      const VerificationMeta('payload');
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
      'payload', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
      'created_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, userId, notificationType, subjectKey, payload, createdAt, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_notifications';
  @override
  VerificationContext validateIntegrity(Insertable<UserNotification> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    } else if (isInserting) {
      context.missing(_userIdMeta);
    }
    if (data.containsKey('notification_type')) {
      context.handle(
          _notificationTypeMeta,
          notificationType.isAcceptableOrUnknown(
              data['notification_type']!, _notificationTypeMeta));
    } else if (isInserting) {
      context.missing(_notificationTypeMeta);
    }
    if (data.containsKey('subject_key')) {
      context.handle(
          _subjectKeyMeta,
          subjectKey.isAcceptableOrUnknown(
              data['subject_key']!, _subjectKeyMeta));
    } else if (isInserting) {
      context.missing(_subjectKeyMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(_payloadMeta,
          payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserNotification map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserNotification(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      notificationType: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}notification_type'])!,
      subjectKey: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}subject_key'])!,
      payload: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payload']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $UserNotificationsTable createAlias(String alias) {
    return $UserNotificationsTable(attachedDatabase, alias);
  }
}

class UserNotification extends DataClass
    implements Insertable<UserNotification> {
  /// UUID v4 string.
  final String id;
  final String userId;

  /// Open string namespace. First value: 'card_detail_update'.
  final String notificationType;

  /// Type-specific aggregation key. For card_detail_update: factId.
  final String subjectKey;

  /// Opaque JSON blob defined by the producer. Null allowed.
  final String? payload;

  /// Seconds since epoch.
  final int createdAt;

  /// Seconds since epoch.
  final int updatedAt;
  const UserNotification(
      {required this.id,
      required this.userId,
      required this.notificationType,
      required this.subjectKey,
      this.payload,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['notification_type'] = Variable<String>(notificationType);
    map['subject_key'] = Variable<String>(subjectKey);
    if (!nullToAbsent || payload != null) {
      map['payload'] = Variable<String>(payload);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  UserNotificationsCompanion toCompanion(bool nullToAbsent) {
    return UserNotificationsCompanion(
      id: Value(id),
      userId: Value(userId),
      notificationType: Value(notificationType),
      subjectKey: Value(subjectKey),
      payload: payload == null && nullToAbsent
          ? const Value.absent()
          : Value(payload),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory UserNotification.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserNotification(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      notificationType: serializer.fromJson<String>(json['notificationType']),
      subjectKey: serializer.fromJson<String>(json['subjectKey']),
      payload: serializer.fromJson<String?>(json['payload']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'notificationType': serializer.toJson<String>(notificationType),
      'subjectKey': serializer.toJson<String>(subjectKey),
      'payload': serializer.toJson<String?>(payload),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  UserNotification copyWith(
          {String? id,
          String? userId,
          String? notificationType,
          String? subjectKey,
          Value<String?> payload = const Value.absent(),
          int? createdAt,
          int? updatedAt}) =>
      UserNotification(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        notificationType: notificationType ?? this.notificationType,
        subjectKey: subjectKey ?? this.subjectKey,
        payload: payload.present ? payload.value : this.payload,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  UserNotification copyWithCompanion(UserNotificationsCompanion data) {
    return UserNotification(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      notificationType: data.notificationType.present
          ? data.notificationType.value
          : this.notificationType,
      subjectKey:
          data.subjectKey.present ? data.subjectKey.value : this.subjectKey,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserNotification(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('notificationType: $notificationType, ')
          ..write('subjectKey: $subjectKey, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, userId, notificationType, subjectKey, payload, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserNotification &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.notificationType == this.notificationType &&
          other.subjectKey == this.subjectKey &&
          other.payload == this.payload &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class UserNotificationsCompanion extends UpdateCompanion<UserNotification> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> notificationType;
  final Value<String> subjectKey;
  final Value<String?> payload;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const UserNotificationsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.notificationType = const Value.absent(),
    this.subjectKey = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserNotificationsCompanion.insert({
    required String id,
    required String userId,
    required String notificationType,
    required String subjectKey,
    this.payload = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        userId = Value(userId),
        notificationType = Value(notificationType),
        subjectKey = Value(subjectKey),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<UserNotification> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? notificationType,
    Expression<String>? subjectKey,
    Expression<String>? payload,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (notificationType != null) 'notification_type': notificationType,
      if (subjectKey != null) 'subject_key': subjectKey,
      if (payload != null) 'payload': payload,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserNotificationsCompanion copyWith(
      {Value<String>? id,
      Value<String>? userId,
      Value<String>? notificationType,
      Value<String>? subjectKey,
      Value<String?>? payload,
      Value<int>? createdAt,
      Value<int>? updatedAt,
      Value<int>? rowid}) {
    return UserNotificationsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      notificationType: notificationType ?? this.notificationType,
      subjectKey: subjectKey ?? this.subjectKey,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (notificationType.present) {
      map['notification_type'] = Variable<String>(notificationType.value);
    }
    if (subjectKey.present) {
      map['subject_key'] = Variable<String>(subjectKey.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserNotificationsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('notificationType: $notificationType, ')
          ..write('subjectKey: $subjectKey, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TasksTable tasks = $TasksTable(this);
  late final $KvStoreTable kvStore = $KvStoreTable(this);
  late final $AgentActivityMessagesTable agentActivityMessages =
      $AgentActivityMessagesTable(this);
  late final $CardCacheTable cardCache = $CardCacheTable(this);
  late final $SystemActionsTable systemActions = $SystemActionsTable(this);
  late final $ClarificationRequestsTable clarificationRequests =
      $ClarificationRequestsTable(this);
  late final $PersonaChatMessagesTable personaChatMessages =
      $PersonaChatMessagesTable(this);
  late final $UserNotificationsTable userNotifications =
      $UserNotificationsTable(this);
  late final CardDao cardDao = CardDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        tasks,
        kvStore,
        agentActivityMessages,
        cardCache,
        systemActions,
        clarificationRequests,
        personaChatMessages,
        userNotifications
      ];
}

typedef $$TasksTableCreateCompanionBuilder = TasksCompanion Function({
  required String id,
  required String type,
  Value<String?> payload,
  required String status,
  Value<int> priority,
  Value<int?> createdAt,
  Value<int?> scheduledAt,
  Value<int?> completedAt,
  Value<int?> updatedAt,
  Value<int> retryCount,
  Value<int> maxRetries,
  Value<String?> error,
  Value<String?> result,
  Value<String?> bizId,
  Value<String?> dependencies,
  Value<int> rowid,
});
typedef $$TasksTableUpdateCompanionBuilder = TasksCompanion Function({
  Value<String> id,
  Value<String> type,
  Value<String?> payload,
  Value<String> status,
  Value<int> priority,
  Value<int?> createdAt,
  Value<int?> scheduledAt,
  Value<int?> completedAt,
  Value<int?> updatedAt,
  Value<int> retryCount,
  Value<int> maxRetries,
  Value<String?> error,
  Value<String?> result,
  Value<String?> bizId,
  Value<String?> dependencies,
  Value<int> rowid,
});

class $$TasksTableFilterComposer extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get scheduledAt => $composableBuilder(
      column: $table.scheduledAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get maxRetries => $composableBuilder(
      column: $table.maxRetries, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get error => $composableBuilder(
      column: $table.error, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get result => $composableBuilder(
      column: $table.result, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bizId => $composableBuilder(
      column: $table.bizId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dependencies => $composableBuilder(
      column: $table.dependencies, builder: (column) => ColumnFilters(column));
}

class $$TasksTableOrderingComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get scheduledAt => $composableBuilder(
      column: $table.scheduledAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get maxRetries => $composableBuilder(
      column: $table.maxRetries, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get error => $composableBuilder(
      column: $table.error, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get result => $composableBuilder(
      column: $table.result, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bizId => $composableBuilder(
      column: $table.bizId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dependencies => $composableBuilder(
      column: $table.dependencies,
      builder: (column) => ColumnOrderings(column));
}

class $$TasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get scheduledAt => $composableBuilder(
      column: $table.scheduledAt, builder: (column) => column);

  GeneratedColumn<int> get completedAt => $composableBuilder(
      column: $table.completedAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
      column: $table.retryCount, builder: (column) => column);

  GeneratedColumn<int> get maxRetries => $composableBuilder(
      column: $table.maxRetries, builder: (column) => column);

  GeneratedColumn<String> get error =>
      $composableBuilder(column: $table.error, builder: (column) => column);

  GeneratedColumn<String> get result =>
      $composableBuilder(column: $table.result, builder: (column) => column);

  GeneratedColumn<String> get bizId =>
      $composableBuilder(column: $table.bizId, builder: (column) => column);

  GeneratedColumn<String> get dependencies => $composableBuilder(
      column: $table.dependencies, builder: (column) => column);
}

class $$TasksTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TasksTable,
    Task,
    $$TasksTableFilterComposer,
    $$TasksTableOrderingComposer,
    $$TasksTableAnnotationComposer,
    $$TasksTableCreateCompanionBuilder,
    $$TasksTableUpdateCompanionBuilder,
    (Task, BaseReferences<_$AppDatabase, $TasksTable, Task>),
    Task,
    PrefetchHooks Function()> {
  $$TasksTableTableManager(_$AppDatabase db, $TasksTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String?> payload = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<int> priority = const Value.absent(),
            Value<int?> createdAt = const Value.absent(),
            Value<int?> scheduledAt = const Value.absent(),
            Value<int?> completedAt = const Value.absent(),
            Value<int?> updatedAt = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<int> maxRetries = const Value.absent(),
            Value<String?> error = const Value.absent(),
            Value<String?> result = const Value.absent(),
            Value<String?> bizId = const Value.absent(),
            Value<String?> dependencies = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TasksCompanion(
            id: id,
            type: type,
            payload: payload,
            status: status,
            priority: priority,
            createdAt: createdAt,
            scheduledAt: scheduledAt,
            completedAt: completedAt,
            updatedAt: updatedAt,
            retryCount: retryCount,
            maxRetries: maxRetries,
            error: error,
            result: result,
            bizId: bizId,
            dependencies: dependencies,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String type,
            Value<String?> payload = const Value.absent(),
            required String status,
            Value<int> priority = const Value.absent(),
            Value<int?> createdAt = const Value.absent(),
            Value<int?> scheduledAt = const Value.absent(),
            Value<int?> completedAt = const Value.absent(),
            Value<int?> updatedAt = const Value.absent(),
            Value<int> retryCount = const Value.absent(),
            Value<int> maxRetries = const Value.absent(),
            Value<String?> error = const Value.absent(),
            Value<String?> result = const Value.absent(),
            Value<String?> bizId = const Value.absent(),
            Value<String?> dependencies = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              TasksCompanion.insert(
            id: id,
            type: type,
            payload: payload,
            status: status,
            priority: priority,
            createdAt: createdAt,
            scheduledAt: scheduledAt,
            completedAt: completedAt,
            updatedAt: updatedAt,
            retryCount: retryCount,
            maxRetries: maxRetries,
            error: error,
            result: result,
            bizId: bizId,
            dependencies: dependencies,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$TasksTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $TasksTable,
    Task,
    $$TasksTableFilterComposer,
    $$TasksTableOrderingComposer,
    $$TasksTableAnnotationComposer,
    $$TasksTableCreateCompanionBuilder,
    $$TasksTableUpdateCompanionBuilder,
    (Task, BaseReferences<_$AppDatabase, $TasksTable, Task>),
    Task,
    PrefetchHooks Function()>;
typedef $$KvStoreTableCreateCompanionBuilder = KvStoreCompanion Function({
  required String key,
  Value<String?> value,
  Value<String?> bucket,
  Value<int?> updatedAt,
  Value<int> rowid,
});
typedef $$KvStoreTableUpdateCompanionBuilder = KvStoreCompanion Function({
  Value<String> key,
  Value<String?> value,
  Value<String?> bucket,
  Value<int?> updatedAt,
  Value<int> rowid,
});

class $$KvStoreTableFilterComposer
    extends Composer<_$AppDatabase, $KvStoreTable> {
  $$KvStoreTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get bucket => $composableBuilder(
      column: $table.bucket, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$KvStoreTableOrderingComposer
    extends Composer<_$AppDatabase, $KvStoreTable> {
  $$KvStoreTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get bucket => $composableBuilder(
      column: $table.bucket, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$KvStoreTableAnnotationComposer
    extends Composer<_$AppDatabase, $KvStoreTable> {
  $$KvStoreTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<String> get bucket =>
      $composableBuilder(column: $table.bucket, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$KvStoreTableTableManager extends RootTableManager<
    _$AppDatabase,
    $KvStoreTable,
    KvStoreData,
    $$KvStoreTableFilterComposer,
    $$KvStoreTableOrderingComposer,
    $$KvStoreTableAnnotationComposer,
    $$KvStoreTableCreateCompanionBuilder,
    $$KvStoreTableUpdateCompanionBuilder,
    (KvStoreData, BaseReferences<_$AppDatabase, $KvStoreTable, KvStoreData>),
    KvStoreData,
    PrefetchHooks Function()> {
  $$KvStoreTableTableManager(_$AppDatabase db, $KvStoreTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KvStoreTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KvStoreTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KvStoreTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String?> value = const Value.absent(),
            Value<String?> bucket = const Value.absent(),
            Value<int?> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              KvStoreCompanion(
            key: key,
            value: value,
            bucket: bucket,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String key,
            Value<String?> value = const Value.absent(),
            Value<String?> bucket = const Value.absent(),
            Value<int?> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              KvStoreCompanion.insert(
            key: key,
            value: value,
            bucket: bucket,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$KvStoreTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $KvStoreTable,
    KvStoreData,
    $$KvStoreTableFilterComposer,
    $$KvStoreTableOrderingComposer,
    $$KvStoreTableAnnotationComposer,
    $$KvStoreTableCreateCompanionBuilder,
    $$KvStoreTableUpdateCompanionBuilder,
    (KvStoreData, BaseReferences<_$AppDatabase, $KvStoreTable, KvStoreData>),
    KvStoreData,
    PrefetchHooks Function()>;
typedef $$AgentActivityMessagesTableCreateCompanionBuilder
    = AgentActivityMessagesCompanion Function({
  Value<int> id,
  required String type,
  required String title,
  Value<String?> content,
  Value<String?> icon,
  Value<String> agentName,
  Value<String?> agentId,
  Value<String?> scene,
  Value<String?> sceneId,
  Value<String?> userId,
  required DateTime timestamp,
});
typedef $$AgentActivityMessagesTableUpdateCompanionBuilder
    = AgentActivityMessagesCompanion Function({
  Value<int> id,
  Value<String> type,
  Value<String> title,
  Value<String?> content,
  Value<String?> icon,
  Value<String> agentName,
  Value<String?> agentId,
  Value<String?> scene,
  Value<String?> sceneId,
  Value<String?> userId,
  Value<DateTime> timestamp,
});

class $$AgentActivityMessagesTableFilterComposer
    extends Composer<_$AppDatabase, $AgentActivityMessagesTable> {
  $$AgentActivityMessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get icon => $composableBuilder(
      column: $table.icon, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get agentName => $composableBuilder(
      column: $table.agentName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get agentId => $composableBuilder(
      column: $table.agentId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get scene => $composableBuilder(
      column: $table.scene, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sceneId => $composableBuilder(
      column: $table.sceneId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));
}

class $$AgentActivityMessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $AgentActivityMessagesTable> {
  $$AgentActivityMessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get icon => $composableBuilder(
      column: $table.icon, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get agentName => $composableBuilder(
      column: $table.agentName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get agentId => $composableBuilder(
      column: $table.agentId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get scene => $composableBuilder(
      column: $table.scene, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sceneId => $composableBuilder(
      column: $table.sceneId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));
}

class $$AgentActivityMessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AgentActivityMessagesTable> {
  $$AgentActivityMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<String> get agentName =>
      $composableBuilder(column: $table.agentName, builder: (column) => column);

  GeneratedColumn<String> get agentId =>
      $composableBuilder(column: $table.agentId, builder: (column) => column);

  GeneratedColumn<String> get scene =>
      $composableBuilder(column: $table.scene, builder: (column) => column);

  GeneratedColumn<String> get sceneId =>
      $composableBuilder(column: $table.sceneId, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);
}

class $$AgentActivityMessagesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AgentActivityMessagesTable,
    AgentActivityMessage,
    $$AgentActivityMessagesTableFilterComposer,
    $$AgentActivityMessagesTableOrderingComposer,
    $$AgentActivityMessagesTableAnnotationComposer,
    $$AgentActivityMessagesTableCreateCompanionBuilder,
    $$AgentActivityMessagesTableUpdateCompanionBuilder,
    (
      AgentActivityMessage,
      BaseReferences<_$AppDatabase, $AgentActivityMessagesTable,
          AgentActivityMessage>
    ),
    AgentActivityMessage,
    PrefetchHooks Function()> {
  $$AgentActivityMessagesTableTableManager(
      _$AppDatabase db, $AgentActivityMessagesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AgentActivityMessagesTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$AgentActivityMessagesTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AgentActivityMessagesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<String?> content = const Value.absent(),
            Value<String?> icon = const Value.absent(),
            Value<String> agentName = const Value.absent(),
            Value<String?> agentId = const Value.absent(),
            Value<String?> scene = const Value.absent(),
            Value<String?> sceneId = const Value.absent(),
            Value<String?> userId = const Value.absent(),
            Value<DateTime> timestamp = const Value.absent(),
          }) =>
              AgentActivityMessagesCompanion(
            id: id,
            type: type,
            title: title,
            content: content,
            icon: icon,
            agentName: agentName,
            agentId: agentId,
            scene: scene,
            sceneId: sceneId,
            userId: userId,
            timestamp: timestamp,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String type,
            required String title,
            Value<String?> content = const Value.absent(),
            Value<String?> icon = const Value.absent(),
            Value<String> agentName = const Value.absent(),
            Value<String?> agentId = const Value.absent(),
            Value<String?> scene = const Value.absent(),
            Value<String?> sceneId = const Value.absent(),
            Value<String?> userId = const Value.absent(),
            required DateTime timestamp,
          }) =>
              AgentActivityMessagesCompanion.insert(
            id: id,
            type: type,
            title: title,
            content: content,
            icon: icon,
            agentName: agentName,
            agentId: agentId,
            scene: scene,
            sceneId: sceneId,
            userId: userId,
            timestamp: timestamp,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AgentActivityMessagesTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $AgentActivityMessagesTable,
        AgentActivityMessage,
        $$AgentActivityMessagesTableFilterComposer,
        $$AgentActivityMessagesTableOrderingComposer,
        $$AgentActivityMessagesTableAnnotationComposer,
        $$AgentActivityMessagesTableCreateCompanionBuilder,
        $$AgentActivityMessagesTableUpdateCompanionBuilder,
        (
          AgentActivityMessage,
          BaseReferences<_$AppDatabase, $AgentActivityMessagesTable,
              AgentActivityMessage>
        ),
        AgentActivityMessage,
        PrefetchHooks Function()>;
typedef $$CardCacheTableCreateCompanionBuilder = CardCacheCompanion Function({
  required String factId,
  required String cardPath,
  required int timestamp,
  required String tags,
  Value<int> rowid,
});
typedef $$CardCacheTableUpdateCompanionBuilder = CardCacheCompanion Function({
  Value<String> factId,
  Value<String> cardPath,
  Value<int> timestamp,
  Value<String> tags,
  Value<int> rowid,
});

class $$CardCacheTableFilterComposer
    extends Composer<_$AppDatabase, $CardCacheTable> {
  $$CardCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get factId => $composableBuilder(
      column: $table.factId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get cardPath => $composableBuilder(
      column: $table.cardPath, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get tags => $composableBuilder(
      column: $table.tags, builder: (column) => ColumnFilters(column));
}

class $$CardCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $CardCacheTable> {
  $$CardCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get factId => $composableBuilder(
      column: $table.factId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get cardPath => $composableBuilder(
      column: $table.cardPath, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get tags => $composableBuilder(
      column: $table.tags, builder: (column) => ColumnOrderings(column));
}

class $$CardCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $CardCacheTable> {
  $$CardCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get factId =>
      $composableBuilder(column: $table.factId, builder: (column) => column);

  GeneratedColumn<String> get cardPath =>
      $composableBuilder(column: $table.cardPath, builder: (column) => column);

  GeneratedColumn<int> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);
}

class $$CardCacheTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CardCacheTable,
    CardCacheData,
    $$CardCacheTableFilterComposer,
    $$CardCacheTableOrderingComposer,
    $$CardCacheTableAnnotationComposer,
    $$CardCacheTableCreateCompanionBuilder,
    $$CardCacheTableUpdateCompanionBuilder,
    (
      CardCacheData,
      BaseReferences<_$AppDatabase, $CardCacheTable, CardCacheData>
    ),
    CardCacheData,
    PrefetchHooks Function()> {
  $$CardCacheTableTableManager(_$AppDatabase db, $CardCacheTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CardCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CardCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CardCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> factId = const Value.absent(),
            Value<String> cardPath = const Value.absent(),
            Value<int> timestamp = const Value.absent(),
            Value<String> tags = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CardCacheCompanion(
            factId: factId,
            cardPath: cardPath,
            timestamp: timestamp,
            tags: tags,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String factId,
            required String cardPath,
            required int timestamp,
            required String tags,
            Value<int> rowid = const Value.absent(),
          }) =>
              CardCacheCompanion.insert(
            factId: factId,
            cardPath: cardPath,
            timestamp: timestamp,
            tags: tags,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CardCacheTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CardCacheTable,
    CardCacheData,
    $$CardCacheTableFilterComposer,
    $$CardCacheTableOrderingComposer,
    $$CardCacheTableAnnotationComposer,
    $$CardCacheTableCreateCompanionBuilder,
    $$CardCacheTableUpdateCompanionBuilder,
    (
      CardCacheData,
      BaseReferences<_$AppDatabase, $CardCacheTable, CardCacheData>
    ),
    CardCacheData,
    PrefetchHooks Function()>;
typedef $$SystemActionsTableCreateCompanionBuilder = SystemActionsCompanion
    Function({
  required String id,
  required String actionType,
  Value<String?> actionData,
  required String status,
  Value<String?> factId,
  Value<int?> createdAt,
  Value<int?> updatedAt,
  Value<int> rowid,
});
typedef $$SystemActionsTableUpdateCompanionBuilder = SystemActionsCompanion
    Function({
  Value<String> id,
  Value<String> actionType,
  Value<String?> actionData,
  Value<String> status,
  Value<String?> factId,
  Value<int?> createdAt,
  Value<int?> updatedAt,
  Value<int> rowid,
});

class $$SystemActionsTableFilterComposer
    extends Composer<_$AppDatabase, $SystemActionsTable> {
  $$SystemActionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get actionType => $composableBuilder(
      column: $table.actionType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get actionData => $composableBuilder(
      column: $table.actionData, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get factId => $composableBuilder(
      column: $table.factId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$SystemActionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SystemActionsTable> {
  $$SystemActionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get actionType => $composableBuilder(
      column: $table.actionType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get actionData => $composableBuilder(
      column: $table.actionData, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get factId => $composableBuilder(
      column: $table.factId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$SystemActionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SystemActionsTable> {
  $$SystemActionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get actionType => $composableBuilder(
      column: $table.actionType, builder: (column) => column);

  GeneratedColumn<String> get actionData => $composableBuilder(
      column: $table.actionData, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get factId =>
      $composableBuilder(column: $table.factId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SystemActionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SystemActionsTable,
    SystemAction,
    $$SystemActionsTableFilterComposer,
    $$SystemActionsTableOrderingComposer,
    $$SystemActionsTableAnnotationComposer,
    $$SystemActionsTableCreateCompanionBuilder,
    $$SystemActionsTableUpdateCompanionBuilder,
    (
      SystemAction,
      BaseReferences<_$AppDatabase, $SystemActionsTable, SystemAction>
    ),
    SystemAction,
    PrefetchHooks Function()> {
  $$SystemActionsTableTableManager(_$AppDatabase db, $SystemActionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SystemActionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SystemActionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SystemActionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> actionType = const Value.absent(),
            Value<String?> actionData = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> factId = const Value.absent(),
            Value<int?> createdAt = const Value.absent(),
            Value<int?> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SystemActionsCompanion(
            id: id,
            actionType: actionType,
            actionData: actionData,
            status: status,
            factId: factId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String actionType,
            Value<String?> actionData = const Value.absent(),
            required String status,
            Value<String?> factId = const Value.absent(),
            Value<int?> createdAt = const Value.absent(),
            Value<int?> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SystemActionsCompanion.insert(
            id: id,
            actionType: actionType,
            actionData: actionData,
            status: status,
            factId: factId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SystemActionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SystemActionsTable,
    SystemAction,
    $$SystemActionsTableFilterComposer,
    $$SystemActionsTableOrderingComposer,
    $$SystemActionsTableAnnotationComposer,
    $$SystemActionsTableCreateCompanionBuilder,
    $$SystemActionsTableUpdateCompanionBuilder,
    (
      SystemAction,
      BaseReferences<_$AppDatabase, $SystemActionsTable, SystemAction>
    ),
    SystemAction,
    PrefetchHooks Function()>;
typedef $$ClarificationRequestsTableCreateCompanionBuilder
    = ClarificationRequestsCompanion Function({
  required String id,
  required String question,
  required String responseType,
  Value<String?> options,
  required String status,
  Value<String?> answerData,
  Value<String?> entityType,
  Value<String?> entityLabel,
  Value<String?> evidenceFactIds,
  Value<String?> reason,
  Value<String?> impact,
  Value<double?> confidence,
  Value<String?> proposedMemory,
  Value<String?> resolutionTarget,
  Value<String?> sourceAgent,
  Value<String?> dedupeKey,
  Value<String?> factId,
  Value<String?> error,
  Value<int?> createdAt,
  Value<int?> updatedAt,
  Value<int?> answeredAt,
  Value<int?> expiresAt,
  Value<int> rowid,
});
typedef $$ClarificationRequestsTableUpdateCompanionBuilder
    = ClarificationRequestsCompanion Function({
  Value<String> id,
  Value<String> question,
  Value<String> responseType,
  Value<String?> options,
  Value<String> status,
  Value<String?> answerData,
  Value<String?> entityType,
  Value<String?> entityLabel,
  Value<String?> evidenceFactIds,
  Value<String?> reason,
  Value<String?> impact,
  Value<double?> confidence,
  Value<String?> proposedMemory,
  Value<String?> resolutionTarget,
  Value<String?> sourceAgent,
  Value<String?> dedupeKey,
  Value<String?> factId,
  Value<String?> error,
  Value<int?> createdAt,
  Value<int?> updatedAt,
  Value<int?> answeredAt,
  Value<int?> expiresAt,
  Value<int> rowid,
});

class $$ClarificationRequestsTableFilterComposer
    extends Composer<_$AppDatabase, $ClarificationRequestsTable> {
  $$ClarificationRequestsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get question => $composableBuilder(
      column: $table.question, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get responseType => $composableBuilder(
      column: $table.responseType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get options => $composableBuilder(
      column: $table.options, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get answerData => $composableBuilder(
      column: $table.answerData, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get entityLabel => $composableBuilder(
      column: $table.entityLabel, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get evidenceFactIds => $composableBuilder(
      column: $table.evidenceFactIds,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get reason => $composableBuilder(
      column: $table.reason, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get impact => $composableBuilder(
      column: $table.impact, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get proposedMemory => $composableBuilder(
      column: $table.proposedMemory,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get resolutionTarget => $composableBuilder(
      column: $table.resolutionTarget,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sourceAgent => $composableBuilder(
      column: $table.sourceAgent, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dedupeKey => $composableBuilder(
      column: $table.dedupeKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get factId => $composableBuilder(
      column: $table.factId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get error => $composableBuilder(
      column: $table.error, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get answeredAt => $composableBuilder(
      column: $table.answeredAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get expiresAt => $composableBuilder(
      column: $table.expiresAt, builder: (column) => ColumnFilters(column));
}

class $$ClarificationRequestsTableOrderingComposer
    extends Composer<_$AppDatabase, $ClarificationRequestsTable> {
  $$ClarificationRequestsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get question => $composableBuilder(
      column: $table.question, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get responseType => $composableBuilder(
      column: $table.responseType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get options => $composableBuilder(
      column: $table.options, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get answerData => $composableBuilder(
      column: $table.answerData, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get entityLabel => $composableBuilder(
      column: $table.entityLabel, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get evidenceFactIds => $composableBuilder(
      column: $table.evidenceFactIds,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get reason => $composableBuilder(
      column: $table.reason, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get impact => $composableBuilder(
      column: $table.impact, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get proposedMemory => $composableBuilder(
      column: $table.proposedMemory,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get resolutionTarget => $composableBuilder(
      column: $table.resolutionTarget,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sourceAgent => $composableBuilder(
      column: $table.sourceAgent, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dedupeKey => $composableBuilder(
      column: $table.dedupeKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get factId => $composableBuilder(
      column: $table.factId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get error => $composableBuilder(
      column: $table.error, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get answeredAt => $composableBuilder(
      column: $table.answeredAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get expiresAt => $composableBuilder(
      column: $table.expiresAt, builder: (column) => ColumnOrderings(column));
}

class $$ClarificationRequestsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ClarificationRequestsTable> {
  $$ClarificationRequestsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get question =>
      $composableBuilder(column: $table.question, builder: (column) => column);

  GeneratedColumn<String> get responseType => $composableBuilder(
      column: $table.responseType, builder: (column) => column);

  GeneratedColumn<String> get options =>
      $composableBuilder(column: $table.options, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get answerData => $composableBuilder(
      column: $table.answerData, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
      column: $table.entityType, builder: (column) => column);

  GeneratedColumn<String> get entityLabel => $composableBuilder(
      column: $table.entityLabel, builder: (column) => column);

  GeneratedColumn<String> get evidenceFactIds => $composableBuilder(
      column: $table.evidenceFactIds, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get impact =>
      $composableBuilder(column: $table.impact, builder: (column) => column);

  GeneratedColumn<double> get confidence => $composableBuilder(
      column: $table.confidence, builder: (column) => column);

  GeneratedColumn<String> get proposedMemory => $composableBuilder(
      column: $table.proposedMemory, builder: (column) => column);

  GeneratedColumn<String> get resolutionTarget => $composableBuilder(
      column: $table.resolutionTarget, builder: (column) => column);

  GeneratedColumn<String> get sourceAgent => $composableBuilder(
      column: $table.sourceAgent, builder: (column) => column);

  GeneratedColumn<String> get dedupeKey =>
      $composableBuilder(column: $table.dedupeKey, builder: (column) => column);

  GeneratedColumn<String> get factId =>
      $composableBuilder(column: $table.factId, builder: (column) => column);

  GeneratedColumn<String> get error =>
      $composableBuilder(column: $table.error, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<int> get answeredAt => $composableBuilder(
      column: $table.answeredAt, builder: (column) => column);

  GeneratedColumn<int> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);
}

class $$ClarificationRequestsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ClarificationRequestsTable,
    ClarificationRequest,
    $$ClarificationRequestsTableFilterComposer,
    $$ClarificationRequestsTableOrderingComposer,
    $$ClarificationRequestsTableAnnotationComposer,
    $$ClarificationRequestsTableCreateCompanionBuilder,
    $$ClarificationRequestsTableUpdateCompanionBuilder,
    (
      ClarificationRequest,
      BaseReferences<_$AppDatabase, $ClarificationRequestsTable,
          ClarificationRequest>
    ),
    ClarificationRequest,
    PrefetchHooks Function()> {
  $$ClarificationRequestsTableTableManager(
      _$AppDatabase db, $ClarificationRequestsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClarificationRequestsTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$ClarificationRequestsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClarificationRequestsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> question = const Value.absent(),
            Value<String> responseType = const Value.absent(),
            Value<String?> options = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<String?> answerData = const Value.absent(),
            Value<String?> entityType = const Value.absent(),
            Value<String?> entityLabel = const Value.absent(),
            Value<String?> evidenceFactIds = const Value.absent(),
            Value<String?> reason = const Value.absent(),
            Value<String?> impact = const Value.absent(),
            Value<double?> confidence = const Value.absent(),
            Value<String?> proposedMemory = const Value.absent(),
            Value<String?> resolutionTarget = const Value.absent(),
            Value<String?> sourceAgent = const Value.absent(),
            Value<String?> dedupeKey = const Value.absent(),
            Value<String?> factId = const Value.absent(),
            Value<String?> error = const Value.absent(),
            Value<int?> createdAt = const Value.absent(),
            Value<int?> updatedAt = const Value.absent(),
            Value<int?> answeredAt = const Value.absent(),
            Value<int?> expiresAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ClarificationRequestsCompanion(
            id: id,
            question: question,
            responseType: responseType,
            options: options,
            status: status,
            answerData: answerData,
            entityType: entityType,
            entityLabel: entityLabel,
            evidenceFactIds: evidenceFactIds,
            reason: reason,
            impact: impact,
            confidence: confidence,
            proposedMemory: proposedMemory,
            resolutionTarget: resolutionTarget,
            sourceAgent: sourceAgent,
            dedupeKey: dedupeKey,
            factId: factId,
            error: error,
            createdAt: createdAt,
            updatedAt: updatedAt,
            answeredAt: answeredAt,
            expiresAt: expiresAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String question,
            required String responseType,
            Value<String?> options = const Value.absent(),
            required String status,
            Value<String?> answerData = const Value.absent(),
            Value<String?> entityType = const Value.absent(),
            Value<String?> entityLabel = const Value.absent(),
            Value<String?> evidenceFactIds = const Value.absent(),
            Value<String?> reason = const Value.absent(),
            Value<String?> impact = const Value.absent(),
            Value<double?> confidence = const Value.absent(),
            Value<String?> proposedMemory = const Value.absent(),
            Value<String?> resolutionTarget = const Value.absent(),
            Value<String?> sourceAgent = const Value.absent(),
            Value<String?> dedupeKey = const Value.absent(),
            Value<String?> factId = const Value.absent(),
            Value<String?> error = const Value.absent(),
            Value<int?> createdAt = const Value.absent(),
            Value<int?> updatedAt = const Value.absent(),
            Value<int?> answeredAt = const Value.absent(),
            Value<int?> expiresAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ClarificationRequestsCompanion.insert(
            id: id,
            question: question,
            responseType: responseType,
            options: options,
            status: status,
            answerData: answerData,
            entityType: entityType,
            entityLabel: entityLabel,
            evidenceFactIds: evidenceFactIds,
            reason: reason,
            impact: impact,
            confidence: confidence,
            proposedMemory: proposedMemory,
            resolutionTarget: resolutionTarget,
            sourceAgent: sourceAgent,
            dedupeKey: dedupeKey,
            factId: factId,
            error: error,
            createdAt: createdAt,
            updatedAt: updatedAt,
            answeredAt: answeredAt,
            expiresAt: expiresAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ClarificationRequestsTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $ClarificationRequestsTable,
        ClarificationRequest,
        $$ClarificationRequestsTableFilterComposer,
        $$ClarificationRequestsTableOrderingComposer,
        $$ClarificationRequestsTableAnnotationComposer,
        $$ClarificationRequestsTableCreateCompanionBuilder,
        $$ClarificationRequestsTableUpdateCompanionBuilder,
        (
          ClarificationRequest,
          BaseReferences<_$AppDatabase, $ClarificationRequestsTable,
              ClarificationRequest>
        ),
        ClarificationRequest,
        PrefetchHooks Function()>;
typedef $$PersonaChatMessagesTableCreateCompanionBuilder
    = PersonaChatMessagesCompanion Function({
  Value<int> id,
  required String characterId,
  required bool isFromCharacter,
  required String content,
  Value<String?> factId,
  Value<bool> isRead,
  required DateTime timestamp,
  Value<String> messageType,
});
typedef $$PersonaChatMessagesTableUpdateCompanionBuilder
    = PersonaChatMessagesCompanion Function({
  Value<int> id,
  Value<String> characterId,
  Value<bool> isFromCharacter,
  Value<String> content,
  Value<String?> factId,
  Value<bool> isRead,
  Value<DateTime> timestamp,
  Value<String> messageType,
});

class $$PersonaChatMessagesTableFilterComposer
    extends Composer<_$AppDatabase, $PersonaChatMessagesTable> {
  $$PersonaChatMessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get characterId => $composableBuilder(
      column: $table.characterId, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isFromCharacter => $composableBuilder(
      column: $table.isFromCharacter,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get factId => $composableBuilder(
      column: $table.factId, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isRead => $composableBuilder(
      column: $table.isRead, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get messageType => $composableBuilder(
      column: $table.messageType, builder: (column) => ColumnFilters(column));
}

class $$PersonaChatMessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $PersonaChatMessagesTable> {
  $$PersonaChatMessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get characterId => $composableBuilder(
      column: $table.characterId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isFromCharacter => $composableBuilder(
      column: $table.isFromCharacter,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get factId => $composableBuilder(
      column: $table.factId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isRead => $composableBuilder(
      column: $table.isRead, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get timestamp => $composableBuilder(
      column: $table.timestamp, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get messageType => $composableBuilder(
      column: $table.messageType, builder: (column) => ColumnOrderings(column));
}

class $$PersonaChatMessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PersonaChatMessagesTable> {
  $$PersonaChatMessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get characterId => $composableBuilder(
      column: $table.characterId, builder: (column) => column);

  GeneratedColumn<bool> get isFromCharacter => $composableBuilder(
      column: $table.isFromCharacter, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get factId =>
      $composableBuilder(column: $table.factId, builder: (column) => column);

  GeneratedColumn<bool> get isRead =>
      $composableBuilder(column: $table.isRead, builder: (column) => column);

  GeneratedColumn<DateTime> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get messageType => $composableBuilder(
      column: $table.messageType, builder: (column) => column);
}

class $$PersonaChatMessagesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PersonaChatMessagesTable,
    PersonaChatMessage,
    $$PersonaChatMessagesTableFilterComposer,
    $$PersonaChatMessagesTableOrderingComposer,
    $$PersonaChatMessagesTableAnnotationComposer,
    $$PersonaChatMessagesTableCreateCompanionBuilder,
    $$PersonaChatMessagesTableUpdateCompanionBuilder,
    (
      PersonaChatMessage,
      BaseReferences<_$AppDatabase, $PersonaChatMessagesTable,
          PersonaChatMessage>
    ),
    PersonaChatMessage,
    PrefetchHooks Function()> {
  $$PersonaChatMessagesTableTableManager(
      _$AppDatabase db, $PersonaChatMessagesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PersonaChatMessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PersonaChatMessagesTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PersonaChatMessagesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> characterId = const Value.absent(),
            Value<bool> isFromCharacter = const Value.absent(),
            Value<String> content = const Value.absent(),
            Value<String?> factId = const Value.absent(),
            Value<bool> isRead = const Value.absent(),
            Value<DateTime> timestamp = const Value.absent(),
            Value<String> messageType = const Value.absent(),
          }) =>
              PersonaChatMessagesCompanion(
            id: id,
            characterId: characterId,
            isFromCharacter: isFromCharacter,
            content: content,
            factId: factId,
            isRead: isRead,
            timestamp: timestamp,
            messageType: messageType,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String characterId,
            required bool isFromCharacter,
            required String content,
            Value<String?> factId = const Value.absent(),
            Value<bool> isRead = const Value.absent(),
            required DateTime timestamp,
            Value<String> messageType = const Value.absent(),
          }) =>
              PersonaChatMessagesCompanion.insert(
            id: id,
            characterId: characterId,
            isFromCharacter: isFromCharacter,
            content: content,
            factId: factId,
            isRead: isRead,
            timestamp: timestamp,
            messageType: messageType,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PersonaChatMessagesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PersonaChatMessagesTable,
    PersonaChatMessage,
    $$PersonaChatMessagesTableFilterComposer,
    $$PersonaChatMessagesTableOrderingComposer,
    $$PersonaChatMessagesTableAnnotationComposer,
    $$PersonaChatMessagesTableCreateCompanionBuilder,
    $$PersonaChatMessagesTableUpdateCompanionBuilder,
    (
      PersonaChatMessage,
      BaseReferences<_$AppDatabase, $PersonaChatMessagesTable,
          PersonaChatMessage>
    ),
    PersonaChatMessage,
    PrefetchHooks Function()>;
typedef $$UserNotificationsTableCreateCompanionBuilder
    = UserNotificationsCompanion Function({
  required String id,
  required String userId,
  required String notificationType,
  required String subjectKey,
  Value<String?> payload,
  required int createdAt,
  required int updatedAt,
  Value<int> rowid,
});
typedef $$UserNotificationsTableUpdateCompanionBuilder
    = UserNotificationsCompanion Function({
  Value<String> id,
  Value<String> userId,
  Value<String> notificationType,
  Value<String> subjectKey,
  Value<String?> payload,
  Value<int> createdAt,
  Value<int> updatedAt,
  Value<int> rowid,
});

class $$UserNotificationsTableFilterComposer
    extends Composer<_$AppDatabase, $UserNotificationsTable> {
  $$UserNotificationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get notificationType => $composableBuilder(
      column: $table.notificationType,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get subjectKey => $composableBuilder(
      column: $table.subjectKey, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$UserNotificationsTableOrderingComposer
    extends Composer<_$AppDatabase, $UserNotificationsTable> {
  $$UserNotificationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get notificationType => $composableBuilder(
      column: $table.notificationType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get subjectKey => $composableBuilder(
      column: $table.subjectKey, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get payload => $composableBuilder(
      column: $table.payload, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$UserNotificationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserNotificationsTable> {
  $$UserNotificationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get notificationType => $composableBuilder(
      column: $table.notificationType, builder: (column) => column);

  GeneratedColumn<String> get subjectKey => $composableBuilder(
      column: $table.subjectKey, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$UserNotificationsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UserNotificationsTable,
    UserNotification,
    $$UserNotificationsTableFilterComposer,
    $$UserNotificationsTableOrderingComposer,
    $$UserNotificationsTableAnnotationComposer,
    $$UserNotificationsTableCreateCompanionBuilder,
    $$UserNotificationsTableUpdateCompanionBuilder,
    (
      UserNotification,
      BaseReferences<_$AppDatabase, $UserNotificationsTable, UserNotification>
    ),
    UserNotification,
    PrefetchHooks Function()> {
  $$UserNotificationsTableTableManager(
      _$AppDatabase db, $UserNotificationsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserNotificationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserNotificationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserNotificationsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> notificationType = const Value.absent(),
            Value<String> subjectKey = const Value.absent(),
            Value<String?> payload = const Value.absent(),
            Value<int> createdAt = const Value.absent(),
            Value<int> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserNotificationsCompanion(
            id: id,
            userId: userId,
            notificationType: notificationType,
            subjectKey: subjectKey,
            payload: payload,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String userId,
            required String notificationType,
            required String subjectKey,
            Value<String?> payload = const Value.absent(),
            required int createdAt,
            required int updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              UserNotificationsCompanion.insert(
            id: id,
            userId: userId,
            notificationType: notificationType,
            subjectKey: subjectKey,
            payload: payload,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UserNotificationsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UserNotificationsTable,
    UserNotification,
    $$UserNotificationsTableFilterComposer,
    $$UserNotificationsTableOrderingComposer,
    $$UserNotificationsTableAnnotationComposer,
    $$UserNotificationsTableCreateCompanionBuilder,
    $$UserNotificationsTableUpdateCompanionBuilder,
    (
      UserNotification,
      BaseReferences<_$AppDatabase, $UserNotificationsTable, UserNotification>
    ),
    UserNotification,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
  $$KvStoreTableTableManager get kvStore =>
      $$KvStoreTableTableManager(_db, _db.kvStore);
  $$AgentActivityMessagesTableTableManager get agentActivityMessages =>
      $$AgentActivityMessagesTableTableManager(_db, _db.agentActivityMessages);
  $$CardCacheTableTableManager get cardCache =>
      $$CardCacheTableTableManager(_db, _db.cardCache);
  $$SystemActionsTableTableManager get systemActions =>
      $$SystemActionsTableTableManager(_db, _db.systemActions);
  $$ClarificationRequestsTableTableManager get clarificationRequests =>
      $$ClarificationRequestsTableTableManager(_db, _db.clarificationRequests);
  $$PersonaChatMessagesTableTableManager get personaChatMessages =>
      $$PersonaChatMessagesTableTableManager(_db, _db.personaChatMessages);
  $$UserNotificationsTableTableManager get userNotifications =>
      $$UserNotificationsTableTableManager(_db, _db.userNotifications);
}
