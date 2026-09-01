// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Thai (`th`).
class AppLocalizationsTh extends AppLocalizations {
  AppLocalizationsTh([String locale = 'th']) : super(locale);

  @override
  String get timesLabel => 'ครั้ง';

  @override
  String modelSetAsDefault(Object modelId) {
    return 'ตั้ง $modelId เป็นโมเดลเริ่มต้น';
  }

  @override
  String get retry => 'ลองอีกครั้ง';

  @override
  String get unknownModel => 'โมเดลที่ไม่รู้จัก';

  @override
  String get notSet => 'ยังไม่ได้ตั้งค่า';

  @override
  String get confirmClear => 'ยืนยันการล้าง';

  @override
  String get confirmClearTokenMessage =>
      'ล้างผู้ใช้ปัจจุบัน? คุณจะต้องป้อนรหัสผู้ใช้อีกครั้ง';

  @override
  String get cancel => 'ยกเลิก';

  @override
  String get confirm => 'ยืนยัน';

  @override
  String get tokenCleared => 'ล้างผู้ใช้แล้ว';

  @override
  String clearTokenFailed(Object error) {
    return 'ล้างผู้ใช้ล้มเหลว: $error';
  }

  @override
  String get selectDateRangeOptional => 'เลือกช่วงวันที่ (ไม่บังคับ):';

  @override
  String get startDate => 'วันที่เริ่มต้น';

  @override
  String get endDate => 'วันที่สิ้นสุด';

  @override
  String get select => 'เลือก';

  @override
  String get processLimitOptional => 'ขีดจำกัดการประมวลผล (ไม่บังคับ)';

  @override
  String get leaveEmptyForAll => 'เว้นว่างเพื่อประมวลผลทั้งหมด';

  @override
  String get startProcessing => 'เริ่มประมวลผล';

  @override
  String get userIdNotFound => 'ไม่พบรหัสผู้ใช้';

  @override
  String createTaskFailed(Object error) {
    return 'สร้างงานล้มเหลว: $error';
  }

  @override
  String get reprocessCards => 'ประมวลผลบัตรใหม่';

  @override
  String get reprocessCardsTaskCreated =>
      'คิวคำขอประมวลผลใหม่ใน Super Agent แล้ว';

  @override
  String get reprocessCardsDownstreamMode => 'ขอบเขต';

  @override
  String get reprocessCardsCardOnly => 'เฉพาะบัตร';

  @override
  String get reprocessCardsCardOnlyDesc =>
      'ขอให้ Super Agent ตรวจสอบและสร้างบัตรไทม์ไลน์ที่เลือกใหม่';

  @override
  String get reprocessCardsRerunDownstream => 'บัตรและการติดตามที่เกี่ยวข้อง';

  @override
  String get reprocessCardsRerunDownstreamDesc =>
      'ขอให้ Super Agent พิจารณาการอัปเดต PKM และข้อมูลเชิงลึกที่เกี่ยวข้องเมื่อจำเป็น';

  @override
  String get reanalyzeMediaAssets => 'อ่านไฟล์แนบสื่ออีกครั้ง';

  @override
  String get reanalyzeMediaAssetsDesc =>
      'ขอให้ Super Agent ตรวจสอบสื่อที่แนบอีกครั้งเมื่อสร้างบัตรใหม่';

  @override
  String get regenerateComments => 'สร้างความคิดเห็นใหม่';

  @override
  String get regenerateCommentsTaskCreated =>
      'สร้างงานสร้างความคิดเห็นใหม่แล้ว กำลังทำงานในพื้นหลัง';

  @override
  String get rebuildSearchIndex => 'สร้างดัชนีการค้นหาใหม่';

  @override
  String get rebuildSearchIndexSuccess => 'สร้างดัชนีการค้นหาใหม่สำเร็จ';

  @override
  String get rebuildSearchIndexFailed => 'สร้างดัชนีการค้นหาใหม่ล้มเหลว';

  @override
  String get clearData => 'ล้างข้อมูล';

  @override
  String get confirmClearDataMessage => 'ล้างข้อมูล?';

  @override
  String get confirmClearDataDeletesWorkspaceMessage =>
      'ข้อมูลพื้นที่ทำงานในเครื่องทั้งหมดของผู้ใช้ปัจจุบันจะถูกลบ รวมถึงบัตร สื่อ ไฟล์ความรู้ ข้อมูลเชิงลึก ความทรงจำ ประวัติแชท และสถานะระบบ\n\nการดำเนินการนี้ไม่สามารถยกเลิกได้!';

  @override
  String get clearFailedAgentContexts => 'ล้างบริบทการสนทนาที่ล้มเหลว';

  @override
  String get confirmClearFailedAgentContextsMessage =>
      'ล้างบริบทการสนทนาที่บันทึกไว้สำหรับ Insight และ Schedule agents? มีประโยชน์หลังเปลี่ยนโมเดลเมื่อข้อความ agent ก่อนหน้าไม่เข้ากัน ข้อเท็จจริง บัตร ความรู้ ความทรงจำ และการตั้งค่าโมเดลจะไม่ถูกลบ';

  @override
  String failedAgentContextsCleared(Object count) {
    return 'ล้างบริบทการสนทนาที่บันทึกไว้ $count รายการ';
  }

  @override
  String clearFailedAgentContextsFailed(Object error) {
    return 'ล้างบริบทการสนทนาล้มเหลว: $error';
  }

  @override
  String get cloneToTestUser => 'โคลนไปยังผู้ใช้ทดสอบ';

  @override
  String get confirmCloneToTestUserMessage =>
      'คัดลอกพื้นที่ทำงานปัจจุบันไปยังผู้ใช้ทดสอบในเครื่องใหม่และสลับไปใช้ สถานะ runtime ของ agent จะไม่ถูกคัดลอก ข้อมูลผู้ใช้ปัจจุบันของคุณจะไม่ถูกแก้ไข';

  @override
  String get testUserIdLabel => 'รหัสผู้ใช้ทดสอบ';

  @override
  String get testUserIdHelper => 'ใช้ตัวอักษร ตัวเลข ขีดกลาง หรือขีดล่าง';

  @override
  String get testUserIdInvalid =>
      'ใช้ได้เฉพาะตัวอักษร ตัวเลข ขีดกลาง หรือขีดล่าง';

  @override
  String get overwriteExistingTestUser => 'แทนที่ผู้ใช้ทดสอบที่มี ID เดียวกัน';

  @override
  String testUserCloneSuccess(Object userId) {
    return 'สลับไปยังผู้ใช้ทดสอบ $userId แล้ว';
  }

  @override
  String testUserCloneFailed(Object error) {
    return 'โคลนผู้ใช้ทดสอบล้มเหลว: $error';
  }

  @override
  String get dataClearedSuccess => 'ล้างข้อมูลสำเร็จ';

  @override
  String clearDataFailed(Object error) {
    return 'ล้างข้อมูลล้มเหลว: $error';
  }

  @override
  String get personalCenter => 'ศูนย์ส่วนตัว';

  @override
  String get viewLogs => 'ดูบันทึก';

  @override
  String get systemAuthorization => 'การอนุญาตระบบ';

  @override
  String get aiCharacterConfig => 'การกำหนดค่าตัวละคร AI';

  @override
  String get modelConfig => 'การกำหนดค่าโมเดล';

  @override
  String get agentConfig => 'การกำหนดค่า Agent';

  @override
  String get experimentalLab => 'Labs';

  @override
  String get experimentalLabDescription =>
      'ฟีเจอร์ทดลองที่อาจเปลี่ยนแปลงหรือย้ายในภายหลัง';

  @override
  String get modelUsageStats => 'สถิติการใช้โมเดล';

  @override
  String get asyncTaskList => 'รายการงานแบบอะซิงโครนัส';

  @override
  String get clearLocalToken => 'ล้างผู้ใช้';

  @override
  String get insightCardTemplates => 'เทมเพลตบัตรข้อมูลเชิงลึก';

  @override
  String get timelineCardTemplates => 'เทมเพลตบัตรไทม์ไลน์';

  @override
  String get logViewer => 'ตัวดูบันทึก';

  @override
  String get autoRefresh => 'รีเฟรชอัตโนมัติ';

  @override
  String get lineCount => 'จำนวนบรรทัด: ';

  @override
  String get all => 'ทั้งหมด';

  @override
  String get schedule => 'ตารางเวลา';

  @override
  String get appLockConfig => 'การกำหนดค่าการล็อกแอป';

  @override
  String loadStatsFailed(Object error) {
    return 'โหลดสถิติล้มเหลว: $error';
  }

  @override
  String get overview => 'ภาพรวม';

  @override
  String get daily => 'รายวัน';

  @override
  String get modelStatsByAgent => 'ตาม agent';

  @override
  String get detail => 'รายละเอียด';

  @override
  String get date => 'วันที่';

  @override
  String get agent => 'Agent';

  @override
  String get noData => 'ไม่มีข้อมูล';

  @override
  String get totalCalls => 'การเรียกทั้งหมด';

  @override
  String get calls => 'การโทร';

  @override
  String callsCount(Object count) {
    return '$count สาย';
  }

  @override
  String get selectDateRange => 'เลือกช่วงวันที่';

  @override
  String get totalTokens => 'โทเค็นทั้งหมด';

  @override
  String get cacheRate => 'อัตราแคช';

  @override
  String get promptTokens => 'โทเค็น prompt';

  @override
  String get completionTokens => 'โทเค็นการตอบ';

  @override
  String get cachedTokens => 'โทเค็นที่แคช';

  @override
  String get thoughtTokens => 'โทเค็นความคิด';

  @override
  String get prompt => 'Prompt';

  @override
  String get completion => 'การเสร็จสมบูรณ์';

  @override
  String get cached => 'แคชแล้ว';

  @override
  String get thought => 'ความคิด';

  @override
  String get model => 'โมเดล';

  @override
  String get scene => 'ฉาก';

  @override
  String get sceneId => 'รหัสฉาก';

  @override
  String get tokenUsage => 'การใช้โทเค็น';

  @override
  String get handler => 'Handler';

  @override
  String get modelBreakdown => 'รายละเอียดโมเดล';

  @override
  String get callDetails => 'รายละเอียดการโทร';

  @override
  String recordDetailsTitle(Object scene) {
    return 'รายละเอียดบันทึก: $scene';
  }

  @override
  String saveLlmConfigFailed(Object error) {
    return 'บันทึกการกำหนดค่า LLM ล้มเหลว: $error';
  }

  @override
  String get webHtmlPreviewUnavailable =>
      'ไม่สามารถแสดงตัวอย่าง HTML บนเว็บได้ โปรดดูบนมือถือ';

  @override
  String saveUserInfoFailed(Object error) {
    return 'บันทึกข้อมูลผู้ใช้ล้มเหลว: $error';
  }

  @override
  String get totalEstimatedCost => 'ค่าใช้จ่ายโดยประมาณทั้งหมด';

  @override
  String get close => 'ปิด';

  @override
  String get totalTokenConsumption => 'การใช้โทเค็นทั้งหมด';

  @override
  String get dataLoadFailedRetry =>
      'โหลดข้อมูลล้มเหลว โปรดลองอีกครั้งในภายหลัง';

  @override
  String get timelineLoadFailedRetry =>
      'โหลดไทม์ไลน์ล้มเหลว โปรดลองอีกครั้งในภายหลัง';

  @override
  String get newPerspective => 'มุมมองใหม่';

  @override
  String get startPoint => 'จุดเริ่มต้น';

  @override
  String get endPoint => 'จุดสิ้นสุด';

  @override
  String get originalInput => 'ข้อมูลป้อนเดิม';

  @override
  String get referenceContent => 'เนื้อหาอ้างอิง';

  @override
  String referenceWithTitle(Object title) {
    return 'อ้างอิง: $title';
  }

  @override
  String get actionCenterTitle => 'การดำเนินการที่รอดำเนินการ';

  @override
  String get noPendingActions => 'ไม่มีการดำเนินการที่รอดำเนินการ';

  @override
  String get clarificationNeeded => 'Memex ต้องการยืนยัน';

  @override
  String get clarificationTextHint => 'พิมพ์คำตอบสั้นๆ';

  @override
  String get clarificationTextRequired => 'เพิ่มคำตอบสั้นๆ ก่อน';

  @override
  String get clarificationAnswered => 'ตอบแล้ว';

  @override
  String clarificationAnswerPrefix(Object answer) {
    return 'คำตอบ: $answer';
  }

  @override
  String get answerSaved => 'บันทึกคำตอบแล้ว';

  @override
  String get clarificationOtherAnswer => 'ป้อนด้วยตนเอง';

  @override
  String get clarificationNotSure => 'ไม่แน่ใจ / ไม่ต้องการตอบ';

  @override
  String get yes => 'ใช่';

  @override
  String get no => 'ไม่';

  @override
  String get footprintMap => 'แผนที่รอยเท้า';

  @override
  String get waypointPlaces => 'สถานที่จุดแวะ';

  @override
  String get unknownPlace => 'สถานที่ที่ไม่รู้จัก';

  @override
  String get releaseToSend => 'ปล่อยเพื่อส่ง';

  @override
  String get selectFromAlbum => 'เลือกจากอัลบั้ม';

  @override
  String get clipboardPreviewTitle => 'คลิปบอร์ดใหม่';

  @override
  String get clipboardPreviewImageTitle => 'รูปภาพในคลิปบอร์ด';

  @override
  String get clipboardPreviewImageDescription => 'รูปภาพพร้อมเพิ่ม';

  @override
  String get clipboardPreviewUnprocessed => 'ยังไม่ได้วาง';

  @override
  String get clipboardPreviewPasteToInput => 'วางลงในช่องป้อน';

  @override
  String get clipboardPreviewAddImageToInput => 'เพิ่มรูปภาพ';

  @override
  String get clipboardPreviewImageFailed => 'ไม่สามารถอ่านรูปภาพจากคลิปบอร์ด';

  @override
  String get tellAiWhatHappened => 'บอก AI ว่าเกิดอะไรขึ้น...';

  @override
  String recordingWithDuration(Object duration) {
    return 'กำลังบันทึก: $duration';
  }

  @override
  String get playing => 'กำลังเล่น...';

  @override
  String get sendLabel => 'ส่ง';

  @override
  String attachedImagesMessage(Object count) {
    return 'ส่งรูปภาพ $count รูป';
  }

  @override
  String get noTaskData => 'ไม่มีข้อมูลงาน';

  @override
  String createdAtDate(Object date) {
    return 'สร้างเมื่อ: $date';
  }

  @override
  String updatedAtDate(Object date) {
    return 'อัปเดต: $date';
  }

  @override
  String durationLabel(Object duration) {
    return 'ระยะเวลา: $duration';
  }

  @override
  String retryCount(Object count) {
    return 'ลองใหม่: $count';
  }

  @override
  String get loadDetailFailedRetry =>
      'โหลดรายละเอียดล้มเหลว โปรดลองอีกครั้งในภายหลัง';

  @override
  String get loadFailed => 'โหลดล้มเหลว';

  @override
  String loadHistoryFailed(Object error) {
    return 'โหลดประวัติล้มเหลว: $error';
  }

  @override
  String get reload => 'โหลดใหม่';

  @override
  String get aiInsightDetail => 'รายละเอียดข้อมูลเชิงลึก';

  @override
  String relatedRecordsCount(Object count) {
    return 'บันทึกที่เกี่ยวข้อง ($count)';
  }

  @override
  String get noRelatedRecords => 'ไม่มีบันทึกที่เกี่ยวข้อง';

  @override
  String get useFingerprintToUnlock => 'ใช้ลายนิ้วมือเพื่อปลดล็อก';

  @override
  String get locked => 'ล็อกแล้ว';

  @override
  String get wrongPassword => 'รหัสผ่านผิด';

  @override
  String get enterPassword => 'ป้อนรหัสผ่าน';

  @override
  String get memexLocked => 'Memex ถูกล็อก';

  @override
  String get calendarShortSun => 'อา.';

  @override
  String get calendarShortMon => 'จ.';

  @override
  String get calendarShortTue => 'อ.';

  @override
  String get calendarShortWed => 'พ.';

  @override
  String get calendarShortThu => 'พฤ.';

  @override
  String get calendarShortFri => 'ศ.';

  @override
  String get calendarShortSat => 'ส.';

  @override
  String noRecordsOnDate(Object date) {
    return 'ไม่มีบันทึกในวันที่ $date';
  }

  @override
  String get footprintPath => 'เส้นทางรอยเท้า';

  @override
  String get lifeCompositionTable => 'องค์ประกอบชีวิต';

  @override
  String get emotionReframe => 'ปรับมุมมองอารมณ์';

  @override
  String get chronicleOfThings => 'บันทึกเหตุการณ์';

  @override
  String get goalProgress => 'ความคืบหน้าเป้าหมาย';

  @override
  String get trendChart => 'แผนภูมิแนวโน้ม';

  @override
  String get comparisonChart => 'แผนภูมิเปรียบเทียบ';

  @override
  String get todayTimeFlow => 'การไหลของเวลาวันนี้';

  @override
  String get aiInputHint =>
      'ไม่ว่าจะเป็นความทรงจำหรือปัจจุบัน ฉันอยู่ที่นี่...';

  @override
  String get refreshSuperAgentStateTooltip => 'ล้างบริบท Memex Agent';

  @override
  String get refreshSuperAgentStateTitle => 'ล้างบริบทประวัติ Memex Agent?';

  @override
  String get refreshSuperAgentStateMessage =>
      'ประวัติแชทที่มองเห็นจะยังอยู่ แต่บริบท runtime ประวัติของ Memex Agent จะถูกล้างและการตอบกลับในอนาคตจะเริ่มจากบริบทใหม่ ความทรงจำถาวร ไฟล์ฐานความรู้ บัตร และข้อมูลที่บันทึกอื่นๆ ไม่ได้รับผลกระทบ ใช้เมื่อ Memex Agent ทำงานผิดปกติซ้ำๆ ดำเนินการต่อ?';

  @override
  String get refreshSuperAgentStateActiveRunMessage =>
      'รอจนกว่าข้อความ Memex Agent ปัจจุบันจะเสร็จก่อนล้างบริบท';

  @override
  String get refreshSuperAgentStateSuccess => 'ล้างบริบท Memex Agent แล้ว';

  @override
  String refreshSuperAgentStateFailed(Object error) {
    return 'ล้างบริบท Memex Agent ล้มเหลว: $error';
  }

  @override
  String get nothingHere => 'ยังไม่มีอะไรที่นี่';

  @override
  String get nothingHereHint => 'แตะปุ่มด้านล่างเพื่อสร้างบัตรแรกของคุณ';

  @override
  String get agentProcessing => 'AI กำลังประมวลผล...';

  @override
  String get keepAppOpen => 'อย่าปิดแอป';

  @override
  String get activityDetail => 'รายละเอียดกิจกรรม';

  @override
  String get noAgentActivityYet => 'ยังไม่มีกิจกรรม agent';

  @override
  String get processingEllipsis => 'กำลังประมวลผล...';

  @override
  String get agentBackgroundTitle => 'Memex Agent';

  @override
  String get agentBackgroundPausedTitle => 'Memex Agent หยุดชั่วคราว';

  @override
  String get agentBackgroundNeedsAttentionTitle =>
      'Memex Agent ต้องการความสนใจ';

  @override
  String get agentBackgroundStageIdle => 'ว่าง';

  @override
  String get agentBackgroundStageProcessing => 'กำลังประมวลผล';

  @override
  String get agentBackgroundStageQueued => 'อยู่ในคิว';

  @override
  String get agentBackgroundStageRetrying => 'กำลังรอลองใหม่';

  @override
  String get agentBackgroundStagePaused => 'หยุดชั่วคราว';

  @override
  String get agentBackgroundStageCompleted => 'เสร็จสิ้น';

  @override
  String get agentBackgroundStageNeedsAttention => 'ต้องการความสนใจ';

  @override
  String get agentBackgroundStageAnalyzingMedia => 'กำลังวิเคราะห์สื่อ';

  @override
  String get agentBackgroundStageGeneratingCard => 'กำลังสร้างบัตร';

  @override
  String get agentBackgroundStageUpdatingKnowledge => 'กำลังอัปเดตความรู้';

  @override
  String get agentBackgroundStagePreparingComment => 'กำลังเตรียมความคิดเห็น';

  @override
  String get agentBackgroundStageRoutingFollowUps => 'กำลังจัดการการติดตาม';

  @override
  String agentBackgroundTaskSummary(
    Object running,
    Object pending,
    Object retrying,
  ) {
    return 'กำลังทำงาน $running, รอดำเนินการ $pending, ลองใหม่ $retrying';
  }

  @override
  String agentBackgroundTaskDetail(Object count) {
    return 'กำลังประมวลผล $count งานในคิว';
  }

  @override
  String get agentBackgroundNoTasks => 'ไม่มีงานพื้นหลัง';

  @override
  String get agentBackgroundStarting => 'กำลังเริ่มการประมวลผล';

  @override
  String get agentBackgroundCompletedDetail =>
      'งานพื้นหลังทั้งหมดเสร็จสิ้นแล้ว';

  @override
  String get agentBackgroundFailedDetail =>
      'การประมวลผลหยุดลงเนื่องจากข้อผิดพลาด';

  @override
  String get agentBackgroundPausedDetail =>
      'การประมวลผลถูกหยุดชั่วคราวและจะดำเนินต่อในภายหลัง';

  @override
  String get agentBackgroundQueuedDetail => 'กำลังรอขั้นตอนการประมวลผลถัดไป';

  @override
  String get agentBackgroundRetryingDetail =>
      'ขั้นตอนปัจจุบันจะลองใหม่อัตโนมัติ';

  @override
  String get agentBackgroundAnalyzeMediaDetail =>
      'กำลังอ่านไฟล์แนบและบริบทในเครื่อง';

  @override
  String get agentBackgroundGeneratingCardDetail =>
      'กำลังแปลงบันทึกเป็นบัตรไทม์ไลน์';

  @override
  String get agentBackgroundUpdatingKnowledgeDetail =>
      'กำลังอัปเดตความรู้และความทรงจำในเครื่อง';

  @override
  String get agentBackgroundPreparingCommentDetail =>
      'กำลังเตรียมการตอบกลับของผู้ช่วย';

  @override
  String get agentBackgroundRoutingFollowUpsDetail =>
      'กำลังตรวจสอบการดำเนินการติดตามสำหรับบัตรนี้';

  @override
  String agentBackgroundPausedStatus(Object summary) {
    return 'หยุดชั่วคราว - $summary';
  }

  @override
  String agentBackgroundNeedsAttentionStatus(Object summary) {
    return 'ต้องการความสนใจ - $summary';
  }

  @override
  String get settings => 'การตั้งค่า';

  @override
  String get languageSettings => 'ภาษา';

  @override
  String get languageSettingsDesc => 'เปลี่ยนภาษาที่แสดงในแอป';

  @override
  String get noPendingActionsToast => 'ไม่มีการดำเนินการที่รอดำเนินการ';

  @override
  String get knowledgeNewDiscovery => 'การค้นพบความรู้ใหม่';

  @override
  String discoveredNewInsightsCount(Object count) {
    return 'พบข้อมูลเชิงลึกใหม่ $count รายการ';
  }

  @override
  String updatedExistingInsightsCount(Object count) {
    return 'อัปเดตข้อมูลเชิงลึกที่มีอยู่ $count รายการ';
  }

  @override
  String get sectionNewInsights => 'ข้อมูลเชิงลึกใหม่';

  @override
  String get sectionUpdatedInsights => 'ข้อมูลเชิงลึกที่อัปเดต';

  @override
  String get unnamedInsight => 'ข้อมูลเชิงลึกไม่มีชื่อ';

  @override
  String get copiedToClipboard => 'คัดลอกไปยังคลิปบอร์ดแล้ว';

  @override
  String get copy => 'คัดลอก';

  @override
  String get selectedLocation => 'ตำแหน่งที่เลือก';

  @override
  String get confirmLocationName => 'ยืนยันชื่อตำแหน่ง';

  @override
  String get confirmLocationNameHint =>
      'คุณสามารถแก้ไขชื่อได้ (พิกัดยังคงเดิม)';

  @override
  String get nameLabel => 'ชื่อ';

  @override
  String get inputPlaceNameHint => 'ป้อนชื่อสถานที่...';

  @override
  String currentCoordinates(Object lat, Object lng) {
    return 'พิกัด: $lat, $lng';
  }

  @override
  String get confirmLocation => 'ยืนยันตำแหน่ง';

  @override
  String get welcomeToMemex => 'ยินดีต้อนรับสู่ Memex';

  @override
  String get createUserIdToStart => 'สร้างโปรไฟล์ของคุณ';

  @override
  String get userIdLabel => 'ชื่อ / ชื่อเล่นของคุณ';

  @override
  String get userIdHint => 'ป้อนชื่อหรือชื่อเล่นของคุณ';

  @override
  String get pleaseEnterUserId => 'โปรดป้อนชื่อของคุณ';

  @override
  String get userIdMaxLength => 'ชื่อต้องไม่เกิน 50 ตัวอักษร';

  @override
  String get startUsing => 'ดำเนินการต่อ';

  @override
  String get userIdTip => 'จะใช้เพื่อปรับแต่งประสบการณ์ของคุณ';

  @override
  String get setupModelConfigTitle => 'ตั้งค่าโมเดล AI';

  @override
  String get setupModelConfigSubtitle =>
      'Memex ต้องการโมเดล AI ระดับแนวหน้าเพื่อจัดระเบียบบันทึก วิเคราะห์รูปภาพ และสร้างข้อมูลเชิงลึก เลือกวิธีการเชื่อมต่อหนึ่งวิธี';

  @override
  String get setupModelConfigComplete => 'เสร็จสิ้นและไปต่อ';

  @override
  String get aiService => 'บริการโมเดล Memex';

  @override
  String get aiModelHubTitle => 'โมเดลและบริการ AI';

  @override
  String get aiModelHubSubtitle =>
      'เลือกบริการอย่างเป็นทางการของ Memex หรือนำผู้ให้บริการของคุณเองมาใช้ การกำหนดเส้นทางโมเดลขั้นสูงยังคงพร้อมใช้งานเมื่อคุณต้องการ';

  @override
  String get aiSetupCurrentStatusTitle => 'การตั้งค่าปัจจุบัน';

  @override
  String get aiSetupStatusNotConfiguredTitle => 'ยังไม่ได้กำหนดค่าบริการ AI';

  @override
  String get aiSetupStatusNotConfiguredDescription =>
      'เลือกวิธีการเชื่อมต่อหนึ่งวิธีเพื่อเปิดใช้งานการจัดระเบียบ AI สำหรับบันทึก สื่อ และข้อมูลเชิงลึก';

  @override
  String get aiSetupStatusMemexTitle => 'ใช้บริการอย่างเป็นทางการของ MemeX';

  @override
  String get aiSetupStatusMemexDescription =>
      'Memex จะใช้การเชื่อมต่ออย่างเป็นทางการและข้อมูลรับรอง API ที่จัดการโดยบัญชี MemeX ของคุณ';

  @override
  String get aiSetupStatusCustomTitle => 'ใช้การตั้งค่าผู้ให้บริการแบบกำหนดเอง';

  @override
  String get aiSetupStatusCustomDescription =>
      'Memex จะใช้ข้อมูลรับรองผู้ให้บริการและการเลือกบทบาทโมเดลที่คุณกำหนดค่า';

  @override
  String get aiSetupChooseConnectionTitle => 'เลือกวิธีการเชื่อมต่อ';

  @override
  String get aiSetupChooseConnectionDescription =>
      'เริ่มต้นด้วยวิธีที่ตรงกับวิธีที่คุณต้องการให้ Memex เข้าถึงโมเดล AI';

  @override
  String get aiSetupOfficialRouteDescription =>
      'ลงชื่อเข้าใช้ MemeX และใช้บริการอย่างเป็นทางการโดยไม่ต้องเลือกผู้ให้บริการ key หรือโมเดลระดับ agent';

  @override
  String get aiSetupCustomRouteDescription =>
      'เพิ่มข้อมูลรับรองผู้ให้บริการของคุณ เลือกโมเดลที่ Super Agent ควรใช้ และแทนที่โมเดลต่อ agent ได้ตามต้องการ';

  @override
  String get aiSetupCustomPageTitle => 'บริการ AI แบบกำหนดเอง';

  @override
  String get aiSetupCustomPageSubtitle =>
      'กำหนดค่าข้อมูลรับรองผู้ให้บริการก่อน จากนั้นเลือกโมเดลที่ Memex ควรใช้';

  @override
  String get aiSetupProviderCredentialsTitle => 'ผู้ให้บริการและ API keys';

  @override
  String get aiSetupProviderCredentialsDescription =>
      'เพิ่มหรือแก้ไข OpenAI, Anthropic, DeepSeek, Gemini, OpenRouter, Ollama หรือผู้ให้บริการที่เข้ากันได้อื่น';

  @override
  String get modelRolesTitle => 'เลือกโมเดลหลัก';

  @override
  String get modelRolesDescription =>
      'Super Agent ใช้โมเดลเดียวสำหรับข้อความและรูปภาพ การแทนที่ agent ขั้นสูงยังมีด้านล่าง';

  @override
  String get textModelRoleTitle => 'โมเดลหลัก';

  @override
  String get textModelRoleDescription =>
      'Super Agent ใช้สำหรับข้อความ รูปภาพ บัตร ความรู้ ข้อมูลเชิงลึก แชท ความคิดเห็น และความทรงจำ';

  @override
  String get modelConnectionsTitle => 'ผู้ให้บริการโมเดลและ API keys';

  @override
  String get modelConnectionsDescription =>
      'เชื่อมต่อบริการอย่างเป็นทางการของ Memex หรือเพิ่มข้อมูลรับรองผู้ให้บริการของคุณเอง';

  @override
  String get relatedAiCapabilitiesTitle => 'ความสามารถขั้นสูงและที่เกี่ยวข้อง';

  @override
  String get relatedAiCapabilitiesDescription =>
      'ปรับแต่งการกำหนด agent ผู้ให้บริการตำแหน่ง และพฤติกรรมการถอดเสียง';

  @override
  String get aiSetupServiceCapabilitiesTitle => 'ความสามารถของบริการ';

  @override
  String get aiSetupServiceCapabilitiesDescription =>
      'เลือกผู้ให้บริการที่ Memex ใช้สำหรับความสามารถ AI ที่เกี่ยวข้อง เช่น การพูดและ reverse geocoding';

  @override
  String get aiSetupAdvancedCustomizationTitle => 'การกำหนดเส้นทางโมเดลขั้นสูง';

  @override
  String get aiSetupAdvancedCustomizationDescription =>
      'สำหรับผู้ใช้ขั้นสูงที่ต้องการให้แต่ละ agent ใช้ผู้ให้บริการหรือการกำหนดค่าโมเดลที่แตกต่างกัน';

  @override
  String get locationProviderSettings => 'ผู้ให้บริการตำแหน่ง';

  @override
  String get speechProviderSettings => 'การถอดเสียง';

  @override
  String get advancedAgentModelAssignments => 'การกำหนดโมเดลของ Agent';

  @override
  String get openAdvancedAgentModelAssignments => 'แทนที่ agent แต่ละตัว';

  @override
  String get noConfiguredModelOptions =>
      'เพิ่มผู้ให้บริการหรือ API key ก่อนเลือกบทบาทโมเดล';

  @override
  String get modelSlotUpdated => 'อัปเดตบทบาทโมเดลแล้ว';

  @override
  String get aiServiceMemexRouteTitle => 'เชื่อมต่อผ่าน Memex';

  @override
  String get aiServiceLongDescription =>
      'Memex ใช้ระบบ multi-agent เพื่อจัดระเบียบบันทึกชีวิต บันทึกความรู้ และบริบททางสังคม ค้นหาข้อมูลเชิงลึกที่ลึกซึ้งยิ่งขึ้น และให้การเป็นเพื่อน AI ที่มีความทรงจำถาวร ข้อมูลของคุณจัดเก็บเป็น Markdown ข้อความธรรมดา รักษาอิสระและความสามารถในการพกพาของข้อมูล';

  @override
  String get aiServiceCustomApiRouteTitle => 'ฉันมี API key';

  @override
  String get aiServiceCustomModelDescription =>
      'เลือกตัวเลือกนี้ก่อนหากคุณมี API key จาก OpenAI, Anthropic, DeepSeek, Gemini หรือผู้ให้บริการอื่น';

  @override
  String get enableAiService => 'เชื่อมต่อด้วย Memex';

  @override
  String get aiServiceReadyToast => 'เปิดการจัดระเบียบ AI แล้ว';

  @override
  String get aiServiceSettingsDescription =>
      'หากคุณไม่มี API key ให้ใช้บัญชี Memex เพื่อเชื่อมต่อกับบริการโมเดลหลัก';

  @override
  String get advancedModelConfiguration => 'กำหนดค่า API key';

  @override
  String get skipForNow => 'ข้ามไปก่อน';

  @override
  String get clearAuth => 'ล้างการยืนยันตัวตน';

  @override
  String get authorizing => 'กำลังอนุญาต...';

  @override
  String authFailed(Object error) {
    return 'การยืนยันตัวตนล้มเหลว: $error';
  }

  @override
  String get authorized => 'อนุญาตแล้ว';

  @override
  String authorizedAs(Object email) {
    return 'อนุญาตในชื่อ $email';
  }

  @override
  String get authorizedSuccessfully => 'อนุญาตสำเร็จ';

  @override
  String get reAuthorize => 'อนุญาตอีกครั้ง';

  @override
  String get authorizeWithOpenAi => 'อนุญาตด้วย OpenAI';

  @override
  String get authorizeWithGoogle => 'อนุญาตด้วย Google';

  @override
  String get config => 'การกำหนดค่า';

  @override
  String get calendar => 'ปฏิทิน';

  @override
  String get reminders => 'การเตือนความจำ';

  @override
  String get writeToSystemFailed => 'เขียนไปยังระบบล้มเหลว';

  @override
  String permissionRequired(Object name) {
    return 'ต้องการสิทธิ์ $name';
  }

  @override
  String permissionRationale(Object name) {
    return 'โปรดอนุญาตให้แอปเข้าถึง $name ของคุณในการตั้งค่าเพื่อให้เราสร้างให้คุณได้';
  }

  @override
  String get goToSettings => 'ไปที่การตั้งค่า';

  @override
  String get unknownAction => 'การดำเนินการที่ไม่รู้จัก';

  @override
  String get discoveredCalendarEvent => 'กิจกรรมในปฏิทินรอการยืนยัน';

  @override
  String get discoveredReminder => 'การเตือนความจำรอการยืนยัน';

  @override
  String get addToCalendar => 'เพิ่มในปฏิทิน';

  @override
  String get addToReminders => 'เพิ่มในการเตือนความจำ';

  @override
  String get systemActionPendingExplanation =>
      'ยังไม่ได้เพิ่ม แตะด้านล่างเพื่อขอสิทธิ์และเพิ่มในอุปกรณ์ของคุณ';

  @override
  String addedToSuccess(Object target) {
    return 'เพิ่มใน $target สำเร็จแล้ว';
  }

  @override
  String get ignore => 'เพิกเฉย';

  @override
  String get confirmDelete => 'ยืนยันการลบ';

  @override
  String get confirmDeleteSessionMessage =>
      'ลบการสนทนานี้? การดำเนินการนี้ไม่สามารถยกเลิกได้';

  @override
  String get delete => 'ลบ';

  @override
  String get deleteSuccess => 'ลบสำเร็จ';

  @override
  String deleteFailed(Object error) {
    return 'ลบล้มเหลว: $error';
  }

  @override
  String daysAgo(Object count) {
    return '$count วันที่แล้ว';
  }

  @override
  String get chatHistory => 'ประวัติแชท';

  @override
  String get enterFullScreenTooltip => 'เข้าโหมดเต็มหน้าจอ';

  @override
  String get exitFullScreenTooltip => 'ออกจากโหมดเต็มหน้าจอ';

  @override
  String get noConversations => 'ไม่มีการสนทนา';

  @override
  String loadSessionListFailed(Object error) {
    return 'โหลดรายการเซสชันล้มเหลว: $error';
  }

  @override
  String yesterdayAt(Object time) {
    return 'เมื่อวาน $time';
  }

  @override
  String get newChat => 'แชทใหม่';

  @override
  String messageCount(Object count) {
    return '$count ข้อความ';
  }

  @override
  String get organize => 'จัดระเบียบ';

  @override
  String get pkmCategoryProject => 'Projects';

  @override
  String get pkmCategoryProjectSubtitle => 'ระยะสั้น · เป้าหมาย · กำหนดเวลา';

  @override
  String get pkmCategoryArea => 'Areas';

  @override
  String get pkmCategoryAreaSubtitle => 'ระยะยาว · ความรับผิดชอบ · มาตรฐาน';

  @override
  String get pkmCategoryResource => 'Resources';

  @override
  String get pkmCategoryResourceSubtitle => 'ความสนใจ · แรงบันดาลใจ · สำรอง';

  @override
  String get pkmCategoryArchive => 'Archives';

  @override
  String get pkmCategoryArchiveSubtitle => 'เสร็จแล้ว · ไม่ใช้งาน · อ้างอิง';

  @override
  String get recentChanges => 'การเปลี่ยนแปลงล่าสุด';

  @override
  String get noRecentChangesInThreeDays =>
      'ไม่มีการเปลี่ยนแปลงใน 3 วันที่ผ่านมา';

  @override
  String get unpinned => 'เลิกปักหมุดแล้ว';

  @override
  String get pinnedStyle => 'ปักหมุดสไตล์แล้ว';

  @override
  String operationFailed(Object error) {
    return 'ดำเนินการล้มเหลว: $error';
  }

  @override
  String get refreshingInsightData =>
      'กำลังรีเฟรชข้อมูลเชิงลึก อาจใช้เวลาสักครู่...';

  @override
  String refreshFailed(Object error) {
    return 'รีเฟรชล้มเหลว: $error';
  }

  @override
  String get sortUpdated => 'อัปเดตลำดับการจัดเรียงแล้ว';

  @override
  String sortSaveFailed(Object error) {
    return 'บันทึกการจัดเรียงล้มเหลว: $error';
  }

  @override
  String get insightCardDeleted => 'ลบบัตรข้อมูลเชิงลึกแล้ว';

  @override
  String deleteFailedShort(Object error) {
    return 'ลบล้มเหลว: $error';
  }

  @override
  String get knowledgeInsight => 'ข้อมูลเชิงลึกความรู้';

  @override
  String get completeSort => 'จัดเรียงเสร็จ';

  @override
  String get noKnowledgeInsight => 'ไม่มีข้อมูลเชิงลึกความรู้';

  @override
  String insightProcessingBacklogMessage(Object count) {
    return 'ยังมีงานพื้นหลัง $count งานกำลังประมวลผล';
  }

  @override
  String get insightUnavailableMessage =>
      'ข้อมูลเชิงลึกนี้ยังกำลังสร้างหรือถูกอัปเดต รีเฟรชข้อมูลเชิงลึกแล้วลองอีกครั้งในภายหลัง';

  @override
  String get artifactOpen => 'เปิด';

  @override
  String get updating => 'กำลังอัปเดต...';

  @override
  String get update => 'อัปเดต';

  @override
  String get enabled => 'เปิดใช้งาน';

  @override
  String get disabled => 'ปิดใช้งาน';

  @override
  String get appLockOn => 'เปิดการล็อกแอป';

  @override
  String get appLockOff => 'ปิดการล็อกแอป';

  @override
  String get enableAppLockFirst => 'โปรดเปิดการล็อกแอปก่อน';

  @override
  String get enterFourDigitPassword => 'ป้อนรหัสผ่าน 4 หลัก';

  @override
  String get passwordSetAndLockOn => 'ตั้งรหัสผ่านและเปิดการล็อกแอปแล้ว';

  @override
  String get appLockSettings => 'การตั้งค่าการล็อกแอป';

  @override
  String get enableAppLock => 'เปิดการล็อกแอป';

  @override
  String get enableAppLockSubtitle => 'ต้องใส่รหัสผ่านเมื่อเปิดแอป';

  @override
  String get enableBiometrics => 'เปิดไบโอเมตริก';

  @override
  String get biometricsSubtitle => 'ใช้ Face ID หรือ Touch ID เพื่อปลดล็อก';

  @override
  String get changePassword => 'เปลี่ยนรหัสผ่าน';

  @override
  String get setFourDigitPassword => 'ตั้งรหัสผ่าน 4 หลัก';

  @override
  String get reenterPasswordToConfirm => 'ป้อนรหัสผ่านอีกครั้งเพื่อยืนยัน';

  @override
  String get passwordMismatch => 'รหัสผ่านไม่ตรงกัน โปรดลองอีกครั้ง';

  @override
  String confirmDeleteCharacter(Object name) {
    return 'ลบตัวละคร \"$name\"? การดำเนินการนี้ไม่สามารถยกเลิกได้';
  }

  @override
  String get configureAiCharacter => 'กำหนดค่าตัวละคร AI';

  @override
  String get addCharacter => 'เพิ่มตัวละคร';

  @override
  String get addCharacterSubtitle =>
      'เลือกตัวละคร AI เพื่อเข้าร่วมทีมข้อมูลเชิงลึกของคุณ พวกเขาจะวิเคราะห์ข้อมูลชีวิตของคุณจากมุมมองต่างๆ';

  @override
  String get noCharacters => 'ไม่มีตัวละคร';

  @override
  String loadCharacterFailed(Object error) {
    return 'โหลดตัวละครล้มเหลว: $error';
  }

  @override
  String get noTags => 'ไม่มีแท็ก';

  @override
  String get createSuccess => 'สร้างสำเร็จ';

  @override
  String get updateSuccess => 'อัปเดตสำเร็จ';

  @override
  String saveFailed(Object error) {
    return 'บันทึกล้มเหลว: $error';
  }

  @override
  String get newCharacter => 'ตัวละครใหม่';

  @override
  String get editCharacter => 'แก้ไขตัวละคร';

  @override
  String get save => 'บันทึก';

  @override
  String get characterName => 'ชื่อตัวละคร';

  @override
  String get characterNameHint => 'ตั้งชื่อให้ตัวละครของคุณ';

  @override
  String get pleaseEnterCharacterName => 'โปรดป้อนชื่อตัวละคร';

  @override
  String get tagsLabel => 'แท็ก';

  @override
  String get tagsHint =>
      'เช่น wisdom, recognition, macro\nแยกหลายแท็กด้วยเครื่องหมายจุลภาค';

  @override
  String get characterPersonaLabel => 'บุคลิกตัวละคร';

  @override
  String get characterPersonaHint =>
      'รวมบุคลิก คู่มือสไตล์ ตัวอย่างบทสนทนา ตัวกรองความรู้ ฯลฯ\nใช้ ## สำหรับหัวข้อส่วน';

  @override
  String get pleaseEnterCharacterPersona => 'โปรดป้อนบุคลิกตัวละคร';

  @override
  String permissionRequestError(Object error) {
    return 'ข้อผิดพลาดการขอสิทธิ์: $error';
  }

  @override
  String get permissionRequiredTitle => 'ต้องการสิทธิ์';

  @override
  String get permissionPermanentlyDeniedMessage =>
      'คุณปฏิเสธสิทธิ์นี้อย่างถาวรหรือระบบต้องการ โปรดเปิดใช้งานในการตั้งค่าระบบ';

  @override
  String get getting => 'กำลังดึง...';

  @override
  String get unauthorized => 'ไม่ได้รับอนุญาต';

  @override
  String get authorizedGoToSettings =>
      'อนุญาตแล้ว ไปที่การตั้งค่าระบบเพื่อเปลี่ยนแปลง';

  @override
  String get location => 'ตำแหน่ง';

  @override
  String get locationPermissionReason =>
      'สำหรับบันทึกสถานที่และฟีเจอร์ที่เกี่ยวกับตำแหน่ง';

  @override
  String get photos => 'รูปภาพ';

  @override
  String get photosPermissionReason =>
      'สำหรับเลือกรูปภาพ บันทึกรูปที่สร้าง ฯลฯ';

  @override
  String get camera => 'กล้อง';

  @override
  String get cameraPermissionReason => 'สำหรับถ่ายภาพและวิดีโอ';

  @override
  String get microphone => 'ไมโครโฟน';

  @override
  String get microphonePermissionReason => 'สำหรับการรู้จำเสียง การบันทึก ฯลฯ';

  @override
  String get calendarPermissionReason =>
      'สำหรับบันทึกตารางเวลาและอ่านกิจกรรมในปฏิทิน';

  @override
  String get remindersPermissionReason =>
      'สำหรับบันทึกและอ่านการเตือนความจำของคุณ';

  @override
  String get fitnessAndMotion => 'Fitness และการเคลื่อนไหว';

  @override
  String get fitnessPermissionReason =>
      'สำหรับบันทึกข้อมูลสุขภาพและการเคลื่อนไหว';

  @override
  String get notification => 'การแจ้งเตือน';

  @override
  String get notificationPermissionReason =>
      'สำหรับส่งตารางเวลาและการเตือนที่สำคัญ';

  @override
  String get memexAgentNotificationPermissionTitle =>
      'ให้ Memex Agent ทำงานในพื้นหลัง';

  @override
  String get memexAgentNotificationPermissionMessage =>
      'Memex Agent ทำงานในเครื่องของคุณ การแจ้งเตือนช่วยให้ Memex แสดงความคืบหน้าและประมวลผลต่อหลังคุณออกจากแอปหรือปิดหน้าจอ หากปิดการแจ้งเตือน ให้เปิด Memex ไว้ที่หน้าจอจนกว่างานจะเสร็จ';

  @override
  String get loadDetailFailedRetryShort =>
      'โหลดรายละเอียดล้มเหลว โปรดลองอีกครั้งในภายหลัง';

  @override
  String get total => 'รวม';

  @override
  String get estimatedCost => 'ค่าใช้จ่ายโดยประมาณ';

  @override
  String get byAgent => 'ตาม Agent';

  @override
  String get timeUpdated => 'อัปเดตเวลาแล้ว';

  @override
  String updateFailed(Object error) {
    return 'อัปเดตล้มเหลว: $error';
  }

  @override
  String get locationUpdated => 'อัปเดตตำแหน่งแล้ว';

  @override
  String get confirmDeleteCardMessage =>
      'ลบบัตรนี้? การดำเนินการนี้ไม่สามารถยกเลิกได้';

  @override
  String get cardDetailNotFound => 'ไม่พบรายละเอียดบัตร';

  @override
  String get saySomething => 'พูดอะไรสักอย่าง...';

  @override
  String get relatedMemories => 'ความทรงจำที่เกี่ยวข้อง';

  @override
  String get viewMore => 'ดูเพิ่มเติม';

  @override
  String get relatedRecords => 'บันทึกที่เกี่ยวข้อง';

  @override
  String get reply => 'ตอบกลับ';

  @override
  String get replySent => 'ส่งการตอบกลับแล้ว';

  @override
  String get insightTemplateGalleryTitle => 'เทมเพลตบัตรข้อมูลเชิงลึก';

  @override
  String get timelineTemplateGalleryTitle => 'เทมเพลตบัตรไทม์ไลน์';

  @override
  String get categoryTextual => 'ข้อความ';

  @override
  String get timelineFilterAll => 'ทั้งหมด';

  @override
  String get insights => 'ข้อมูลเชิงลึก';

  @override
  String get memoryTitle => 'ความทรงจำ';

  @override
  String get longTermProfile => 'โปรไฟล์ระยะยาว';

  @override
  String get recentBuffer => 'บัฟเฟอร์ล่าสุด';

  @override
  String errorLoadingMemory(Object error) {
    return 'โหลดความทรงจำผิดพลาด: $error';
  }

  @override
  String get agentConfiguration => 'การกำหนดค่า Agent';

  @override
  String get resetToDefaults => 'รีเซ็ตเป็นค่าเริ่มต้น';

  @override
  String get resetAllAgentConfigurationsTitle =>
      'รีเซ็ตการกำหนดค่า Agent ทั้งหมด';

  @override
  String get resetAllAgentConfigurationsMessage =>
      'คุณแน่ใจหรือไม่ว่าต้องการรีเซ็ตการกำหนดค่า agent ทั้งหมดเป็นค่าเริ่มต้น? การดำเนินการนี้ไม่สามารถยกเลิกได้';

  @override
  String get resetButton => 'รีเซ็ต';

  @override
  String loadDataFailed(Object error) {
    return 'โหลดข้อมูลล้มเหลว: $error';
  }

  @override
  String saveConfigFailed(Object error) {
    return 'บันทึกการกำหนดค่าล้มเหลว: $error';
  }

  @override
  String get selectLlmClient => 'เลือก LLM Client:';

  @override
  String get agentConfigurationsReset => 'รีเซ็ตการกำหนดค่า Agent แล้ว';

  @override
  String resetFailed(Object error) {
    return 'รีเซ็ตล้มเหลว: $error';
  }

  @override
  String get modelConfiguration => 'การกำหนดค่าโมเดล';

  @override
  String get resetAllConfigurationsTitle => 'รีเซ็ตการกำหนดค่าทั้งหมด';

  @override
  String get resetAllModelConfigurationsMessage =>
      'คุณแน่ใจหรือไม่ว่าต้องการรีเซ็ตการกำหนดค่าโมเดลทั้งหมดเป็นค่าเริ่มต้น? การดำเนินการนี้ไม่สามารถยกเลิกได้';

  @override
  String get modelConfigurationsReset => 'รีเซ็ตการกำหนดค่าโมเดลแล้ว';

  @override
  String get cannotDeleteDefaultConfiguration =>
      'ไม่สามารถลบการกำหนดค่าเริ่มต้น';

  @override
  String get cannotDeleteConfigurationTitle => 'ไม่สามารถลบการกำหนดค่า';

  @override
  String configUsedByAgentsMessage(Object agentList) {
    return 'การกำหนดค่านี้ถูกใช้โดย agent ต่อไปนี้:\n\n$agentList\n\nโปรดกำหนด agent เหล่านี้ใหม่ก่อนลบ';
  }

  @override
  String get ok => 'ตกลง';

  @override
  String get deleteConfigurationTitle => 'ลบการกำหนดค่า';

  @override
  String confirmDeleteConfigMessage(Object key) {
    return 'คุณแน่ใจหรือไม่ว่าต้องการลบ \"$key\"?';
  }

  @override
  String get defaultLabel => 'ค่าเริ่มต้น';

  @override
  String get setAsDefault => 'ตั้งเป็นค่าเริ่มต้น';

  @override
  String get invalidJsonInExtraField => 'JSON ไม่ถูกต้องในช่องเพิ่มเติม';

  @override
  String get keyAlreadyExists => 'มี key นี้อยู่แล้ว';

  @override
  String get resetConfigurationTitle => 'รีเซ็ตการกำหนดค่า';

  @override
  String get resetConfigurationMessage =>
      'รีเซ็ตการกำหนดค่านี้เป็นค่าเริ่มต้นเดิม? การเปลี่ยนแปลงปัจจุบันจะหายไป';

  @override
  String get configurationResetPressSave =>
      'รีเซ็ตการกำหนดค่าแล้ว กดบันทึกเพื่อใช้งาน';

  @override
  String get addConfiguration => 'เพิ่มการกำหนดค่า';

  @override
  String get editConfiguration => 'แก้ไขการกำหนดค่า';

  @override
  String get duplicateConfiguration => 'ทำสำเนาการกำหนดค่า';

  @override
  String get duplicate => 'ทำสำเนา';

  @override
  String get keyIdLabel => 'รหัสการกำหนดค่า';

  @override
  String get keyIdHelper => 'ตั้งชื่อการตั้งค่านี้ เช่น deepseek หรือ work-gpt';

  @override
  String get required => 'จำเป็น';

  @override
  String get clientLabel => 'ผู้ให้บริการโมเดล';

  @override
  String get providerGroupOpenAi => 'OpenAI';

  @override
  String get providerGroupAnthropic => 'Anthropic';

  @override
  String get providerGroupGoogle => 'Google';

  @override
  String get providerGroupOthers => 'ยอดนิยม';

  @override
  String get providerOpenAiApiKey => 'API Key';

  @override
  String get providerOpenAiResponses => 'API Key (Responses)';

  @override
  String get providerChatGptOauth => 'ChatGPT Pro/Plus';

  @override
  String get providerClaudeApiKey => 'API Key';

  @override
  String get providerBedrockSecret => 'Bedrock Secret';

  @override
  String get providerGemini => 'Gemini';

  @override
  String get providerGeminiOauth => 'Gemini (Google OAuth)';

  @override
  String get providerKimi => 'Kimi (Moonshot)';

  @override
  String get providerQwen => 'Aliyun';

  @override
  String get providerSeed => 'Volcengine';

  @override
  String get providerZhipu => 'Zhipu GLM';

  @override
  String get providerDeepSeek => 'DeepSeek';

  @override
  String get providerMinimax => 'MiniMax';

  @override
  String get providerOpenRouter => 'OpenRouter';

  @override
  String get providerOllama => 'Ollama (Local)';

  @override
  String get providerMimo => 'Xiaomi MIMO';

  @override
  String get providerMemex => 'บริการพร็อกซี Memex';

  @override
  String get memexSignIn => 'ลงชื่อเข้าใช้';

  @override
  String get memexCreateAccount => 'สร้างบัญชี';

  @override
  String get memexUsername => 'ชื่อผู้ใช้';

  @override
  String get memexPassword => 'รหัสผ่าน';

  @override
  String get memexCreateAccountLink => 'สร้างบัญชี';

  @override
  String get memexSignInLink => 'ลงชื่อเข้าใช้แทน';

  @override
  String get memexTopUp => 'เติมเงินเพื่อเริ่มใช้ Memex AI';

  @override
  String get memexTopUpSuccess => 'เติมเงินสำเร็จ!';

  @override
  String get memexFillAllFields => 'โปรดกรอกทุกช่อง';

  @override
  String get memexUsernameTooShort => 'ชื่อผู้ใช้ต้องมีอย่างน้อย 6 ตัวอักษร';

  @override
  String get memexAuthFailed => 'การยืนยันตัวตนล้มเหลว';

  @override
  String get memexPaymentFailed => 'สร้างการชำระเงินล้มเหลว';

  @override
  String get memexLogout => 'ออกจากระบบ';

  @override
  String get memexTopUpButton => 'เติมเงิน';

  @override
  String get memexTopUpChooseAmount => 'เลือกจำนวน';

  @override
  String memexTopUpEstimatedRecords(Object range) {
    return 'ประมาณ $range บันทึก';
  }

  @override
  String get memexTopUpPlanStarter => 'เริ่มต้น';

  @override
  String get memexTopUpPlanEveryday => 'ใช้งานประจำ';

  @override
  String get memexTopUpPlanHighVolume => 'ปริมาณสูง';

  @override
  String get memexTopUpPlanCustom => 'เครดิตกำหนดเอง';

  @override
  String get memexTopUpPlanStarterSubtitle => 'เหมาะสำหรับลอง Memex AI';

  @override
  String get memexTopUpPlanEverydaySubtitle =>
      'เหมาะสำหรับการจัดระเบียบเป็นประจำ';

  @override
  String get memexTopUpPlanHighVolumeSubtitle => 'เหมาะสำหรับชุดข้อมูลขนาดใหญ่';

  @override
  String get memexTopUpPlanCustomSubtitle => 'ป้อน USD 1-10,000';

  @override
  String get memexTopUpCustomEstimate => 'การประมาณการอิงตามจำนวนที่ป้อน';

  @override
  String get memexCustomAmount => 'จำนวนกำหนดเอง';

  @override
  String get memexViewHistory => 'ประวัติการใช้งาน';

  @override
  String memexBalanceLabel(Object amount) {
    return 'ยอดคงเหลือ: $amount';
  }

  @override
  String get memexConfirmPassword => 'ยืนยันรหัสผ่าน';

  @override
  String get memexPasswordMismatch => 'รหัสผ่านไม่ตรงกัน';

  @override
  String memexPayAmount(Object amount) {
    return 'เติม $amount';
  }

  @override
  String get modelIdLabel => 'โมเดล';

  @override
  String get modelIdHelper => 'เช่น gemini-3.1-pro-preview, gpt-4o';

  @override
  String get fetchingModels => 'กำลังดึงโมเดล...';

  @override
  String get fetchModelsButton => 'ดึงโมเดล';

  @override
  String get enterApiKeyFirst => 'ป้อน API Key ก่อนเพื่อดึงโมเดล';

  @override
  String get apiKeyLabel => 'API Key';

  @override
  String get baseUrlLabel => 'API endpoint';

  @override
  String get advancedSettings => 'การตั้งค่าขั้นสูง';

  @override
  String get testConnectionSuccess => 'การเชื่อมต่อสำเร็จ';

  @override
  String get testConnectionFailed => 'การเชื่อมต่อล้มเหลว';

  @override
  String get testTypeText => 'ข้อความ';

  @override
  String get testTypeVision => 'Vision';

  @override
  String get testButton => 'ทดสอบ';

  @override
  String get testing => 'กำลังทดสอบ...';

  @override
  String get proxyUrlOptional => 'Proxy URL (ไม่บังคับ)';

  @override
  String get proxyUrlHelper => 'เช่น http://127.0.0.1:7890';

  @override
  String get temperatureLabel => 'Temperature';

  @override
  String get topPLabel => 'Top P';

  @override
  String get maxTokensLabel => 'Max Tokens';

  @override
  String get extraParamsJson => 'พารามิเตอร์เพิ่มเติม (JSON)';

  @override
  String get invalidJson => 'JSON ไม่ถูกต้อง';

  @override
  String get warning => 'การตั้งค่าไม่สมบูรณ์';

  @override
  String get invalidConfigurationWarning =>
      'การกำหนดค่ายังไม่สมบูรณ์ (เช่น ขาด API Key หรือ Model ID) คุณยังบันทึกและกำหนดค่าภายหลังได้ ดำเนินการต่อ?';

  @override
  String invalidModelConfigDetailed(Object agentId, Object configKey) {
    return 'AI Agent \"$agentId\" ต้องการการกำหนดค่าโมเดลที่ถูกต้อง (key: \"$configKey\") เพื่อทำงาน โปรดตรวจสอบการตั้งค่าโมเดล';
  }

  @override
  String get discardChangesTitle => 'ออกจากหน้านี้?';

  @override
  String get discardChangesMessage =>
      'หากคุณทำการเปลี่ยนแปลง โปรดบันทึกก่อนออก';

  @override
  String get discardButton => 'ทิ้ง';

  @override
  String get chooseLanguage => 'เลือกภาษา';

  @override
  String get chooseAvatar => 'เลือกอวตาร';

  @override
  String get configureNow => 'กำหนดค่าตอนนี้';

  @override
  String get modelNotConfiguredBanner =>
      'ยังไม่ได้กำหนดค่าโมเดล AI ตั้งค่าเพื่อปลดล็อกฟีเจอร์ทั้งหมด';

  @override
  String get modelNotConfiguredSubmitHint => 'โปรดกำหนดค่าโมเดล AI ก่อนเผยแพร่';

  @override
  String get processingStatus => 'กำลังประมวลผล';

  @override
  String get failedStatus => 'ล้มเหลว';

  @override
  String get failureReason => 'สาเหตุที่ล้มเหลว';

  @override
  String get unknownError => 'เกิดข้อผิดพลาดที่ไม่ทราบสาเหตุ';

  @override
  String get enableFitness => 'เปิด Fitness';

  @override
  String get fitnessBannerMessage =>
      'อนุญาตการเข้าถึง Fitness เพื่อติดตามข้อมูลสุขภาพและกิจกรรมของคุณ';

  @override
  String get fitnessDismissTitle => 'ข้ามการเข้าถึง Fitness?';

  @override
  String get fitnessDismissMessage =>
      'หากไม่มีสิทธิ์ Fitness แอปจะไม่สามารถรวบรวมข้อมูลสุขภาพอัตโนมัติสำหรับข้อมูลเชิงลึกและการบันทึกอัตโนมัติ';

  @override
  String get skipAnyway => 'ข้ามต่อไป';

  @override
  String get proModelHint => 'โมเดลนี้ต้องการการสมัครสมาชิก ChatGPT Pro/Plus';

  @override
  String get searchKnowledgeBase => 'ค้นหาฐานความรู้...';

  @override
  String get searchKnowledgeHint => 'ป้อนคำสำคัญเพื่อค้นหาชื่อไฟล์หรือเนื้อหา';

  @override
  String noSearchResults(Object query) {
    return 'ไม่พบผลลัพธ์สำหรับ \"$query\"';
  }

  @override
  String get onlyMarkdownPreview => 'รองรับเฉพาะการแสดงตัวอย่าง Markdown';

  @override
  String get backupAndRestore => 'สำรองและกู้คืน';

  @override
  String get createBackup => 'สร้างการสำรองข้อมูล';

  @override
  String get restoreBackup => 'กู้คืนการสำรองข้อมูล';

  @override
  String get backupDescription =>
      'รวมข้อมูลทั้งหมดของคุณ (บัตร ฐานความรู้ ข้อมูลเชิงลึก การตั้งค่า) เป็นไฟล์ .memex บันทึกไว้ใน iCloud Drive, Google Drive หรือตำแหน่งใดก็ได้ผ่านแผ่นแชร์';

  @override
  String get restoreDescription =>
      'เลือกไฟล์สำรอง .memex เพื่อกู้คืนข้อมูลทั้งหมด การดำเนินการนี้จะเขียนทับข้อมูลปัจจุบัน';

  @override
  String get selectBackupFile => 'เลือกไฟล์สำรอง';

  @override
  String get estimatedSize => 'ขนาดโดยประมาณ';

  @override
  String get backupComplete => 'สร้างการสำรองข้อมูลแล้ว';

  @override
  String backupFailed(Object error) {
    return 'การสำรองข้อมูลล้มเหลว: $error';
  }

  @override
  String get confirmRestore => 'ยืนยันการกู้คืน';

  @override
  String get confirmRestoreMessage =>
      'การกู้คืนจะเขียนทับข้อมูลปัจจุบันทั้งหมด รวมถึงบัตร ฐานความรู้ ข้อมูลเชิงลึก และการตั้งค่า การดำเนินการนี้ไม่สามารถยกเลิกได้ ดำเนินการต่อ?';

  @override
  String get restoreComplete => 'กู้คืนเสร็จสิ้น';

  @override
  String get restoreRestartHint =>
      'กู้คืนข้อมูลแล้ว โปรดเริ่มแอปใหม่เพื่อให้การเปลี่ยนแปลงทั้งหมดมีผล';

  @override
  String restoreFailed(Object error) {
    return 'กู้คืนล้มเหลว: $error';
  }

  @override
  String get invalidBackupFile => 'ไฟล์สำรองไม่ถูกต้อง โปรดเลือกไฟล์ .memex';

  @override
  String get automaticBackup => 'การสำรองข้อมูลอัตโนมัติ';

  @override
  String get autoBackupDescription =>
      'เมื่อเปิดใช้งาน Memex จะสร้างสแนปช็อตในเครื่องได้มากที่สุดหนึ่งครั้งต่อวันหลังเริ่มต้นหรือเมื่อกลับมาที่หน้าจอหน้า';

  @override
  String get backupSensitiveSettingsHint =>
      'การสำรองข้อมูลรวมการตั้งค่าและ API keys ของผู้ให้บริการโมเดล เก็บไฟล์สำรองไว้ในที่ที่คุณไว้วางใจ';

  @override
  String get backupLocation => 'ตำแหน่ง';

  @override
  String get backupLocationDetails => 'รายละเอียดตำแหน่ง';

  @override
  String get backupLocationSummary => 'แสดงในแอป';

  @override
  String get backupLocationFullPath => 'เส้นทางเต็ม';

  @override
  String get backupLocationUri => 'Folder access URI';

  @override
  String get copyBackupLocationPath => 'คัดลอกเส้นทาง';

  @override
  String get backupLocationCopied => 'คัดลอกตำแหน่งการสำรองข้อมูลแล้ว';

  @override
  String androidBackupLocationSelected(Object folderName) {
    return 'โฟลเดอร์ที่เลือก: $folderName';
  }

  @override
  String get iosICloudBackupLocation => 'iCloud Drive > Memex > Backups';

  @override
  String get iosAppDocumentsBackupLocation =>
      'Files > On My iPhone > Memex > Backups';

  @override
  String get autoBackupStatus => 'สถานะ';

  @override
  String get noAutoBackupYet => 'ยังไม่มีการสำรองอัตโนมัติ';

  @override
  String lastBackupAt(Object time) {
    return 'สำรองล่าสุด: $time';
  }

  @override
  String get autoBackupRetention => 'การเก็บรักษา';

  @override
  String autoBackupRetentionDays(Object days) {
    return '$days วัน';
  }

  @override
  String get autoBackupRetentionForever => 'เก็บไว้ตลอดไป';

  @override
  String get autoBackupMaxSize => 'ขีดจำกัดพื้นที่จัดเก็บ';

  @override
  String autoBackupRetentionLimitHint(Object size) {
    return 'การล้างอัตโนมัติจะเก็บสแนปช็อตอัตโนมัติไว้ต่ำกว่า $size สแนปช็อตความปลอดภัยและการส่งออกด้วยตนเองจะเก็บแยกต่างหาก';
  }

  @override
  String get createSnapshotNow => 'สำรองตอนนี้';

  @override
  String get backupLocationMenu => 'เปลี่ยนตำแหน่ง';

  @override
  String get defaultBackupLocation => 'โฟลเดอร์สำรองข้อมูลเริ่มต้น';

  @override
  String get defaultBackupLocationAndroidDesc =>
      'ใช้โฟลเดอร์ไฟล์ภายนอกเฉพาะแอปของ Memex ไม่ต้องขอสิทธิ์พื้นที่จัดเก็บ';

  @override
  String get chooseBackupLocation => 'เลือกโฟลเดอร์สำรองข้อมูล';

  @override
  String get chooseBackupLocationAndroidDesc =>
      'เลือกโฟลเดอร์ด้วยตัวเลือกระบบของ Android และให้สิทธิ์การเข้าถึงถาวรแก่ Memex';

  @override
  String get storedBackups => 'การสำรองที่เก็บไว้';

  @override
  String get noStoredBackups => 'การสำรองอัตโนมัติจะปรากฏที่นี่หลังสแนปช็อตแรก';

  @override
  String get backupTypeAutoSnapshot => 'สแนปช็อตอัตโนมัติ';

  @override
  String get backupTypeSafetySnapshot => 'สแนปช็อตความปลอดภัย';

  @override
  String get backupTypeManualBackup => 'การสำรองข้อมูลด้วยตนเอง';

  @override
  String get refresh => 'รีเฟรช';

  @override
  String get restoreThisBackup => 'กู้คืนการสำรองข้อมูลนี้';

  @override
  String get deleteThisBackup => 'ลบการสำรองข้อมูลนี้';

  @override
  String get confirmDeleteBackup => 'ลบการสำรองข้อมูล?';

  @override
  String confirmDeleteBackupMessage(Object fileName) {
    return 'ลบ $fileName? การดำเนินการนี้จะลบไฟล์สำรองที่เก็บไว้และไม่สามารถยกเลิกได้';
  }

  @override
  String backupDeleted(Object fileName) {
    return 'ลบการสำรองข้อมูลแล้ว: $fileName';
  }

  @override
  String backupDeleteFailed(Object error) {
    return 'ไม่สามารถลบการสำรองข้อมูล: $error';
  }

  @override
  String get creatingSafetySnapshot => 'กำลังสร้างสแนปช็อตความปลอดภัย...';

  @override
  String autoBackupCreated(Object fileName) {
    return 'สร้างสแนปช็อตแล้ว: $fileName';
  }

  @override
  String backupLocationFailed(Object error) {
    return 'ไม่สามารถอัปเดตตำแหน่งการสำรองข้อมูล: $error';
  }

  @override
  String get backupImportCreatedAt => 'สร้างเมื่อ';

  @override
  String get backupImportSourceVersion => 'เวอร์ชันต้นทาง';

  @override
  String get backupImportFlavor => 'Build';

  @override
  String get backupLegacyFormat => 'การสำรองข้อมูลแบบเก่า (ไม่มี manifest)';

  @override
  String get restoreInProgress => 'กำลังกู้คืนการสำรองข้อมูล...';

  @override
  String get dataStorage => 'การจัดเก็บข้อมูล';

  @override
  String get dataStorageDescriptionAndroid =>
      'เลือกโฟลเดอร์กำหนดเองเพื่อเก็บพื้นที่ทำงาน ข้อมูลจะคงอยู่เมื่อติดตั้งแอปใหม่';

  @override
  String get dataStorageDescriptionIOS =>
      'เปิด iCloud เพื่อซิงค์พื้นที่ทำงานข้ามอุปกรณ์และเก็บข้อมูลเมื่อติดตั้งแอปใหม่';

  @override
  String get storageLocationApp => 'พื้นที่จัดเก็บในแอป';

  @override
  String get storageLocationAppDesc =>
      'ข้อมูลจัดเก็บในแอปและจะถูกลบเมื่อถอนการติดตั้ง';

  @override
  String get storageLocationCustom =>
      'พื้นที่จัดเก็บอุปกรณ์ (โฟลเดอร์กำหนดเอง)';

  @override
  String get storageLocationCustomDesc =>
      'จัดเก็บข้อมูลในโฟลเดอร์ที่คุณเลือก ข้อมูลคงอยู่หลังติดตั้งใหม่หากโฟลเดอร์ยังอยู่';

  @override
  String get storageLocationICloud => 'จัดเก็บใน iCloud';

  @override
  String get storageLocationICloudDesc =>
      'ซิงค์พื้นที่ทำงานข้ามอุปกรณ์ Apple ข้อมูลยังอยู่หลังติดตั้งใหม่';

  @override
  String storageLocationCurrent(Object location) {
    return 'ปัจจุบัน: $location';
  }

  @override
  String get icloudRequiresCapability =>
      'ลงชื่อเข้าใช้ iCloud และเปิด iCloud Drive เพื่อใช้พื้นที่จัดเก็บ iCloud';

  @override
  String get loadingFromICloud => 'กำลังกู้คืนข้อมูลจาก iCloud…';

  @override
  String get switchingToICloud => 'กำลังสลับไปยังพื้นที่จัดเก็บ iCloud…';

  @override
  String get switchingStorage => 'กำลังสลับพื้นที่จัดเก็บ…';

  @override
  String get customFolderAccessDenied =>
      'ไม่สามารถอ่านหรือเขียนโฟลเดอร์นี้ โปรดให้สิทธิ์พื้นที่จัดเก็บหรือเลือกตำแหน่งอื่น';

  @override
  String get configured => 'กำหนดค่าแล้ว';

  @override
  String get apiKeyNotSet => 'ยังไม่ได้ตั้งค่า API Key — แตะเพื่อกำหนดค่า';

  @override
  String get bottomNavTimeline => 'ไทม์ไลน์';

  @override
  String get bottomNavLibrary => 'คลัง';

  @override
  String get aiGeneratedLabel => 'สร้างโดย AI';

  @override
  String sourceTraceWithCount(Object count) {
    return 'ติดตามแหล่งที่มา ($count)';
  }

  @override
  String get deleteAccount => 'ลบบัญชี';

  @override
  String get deleteAccountDesc =>
      'ลบข้อมูลในเครื่องทั้งหมดอย่างถาวรและรีเซ็ตแอป';

  @override
  String get deleteAccountConfirmTitle => 'ลบบัญชี?';

  @override
  String get deleteAccountConfirmMessage =>
      'การดำเนินการนี้จะลบข้อมูลทั้งหมดของคุณอย่างถาวร รวมถึงบัตรไทม์ไลน์ ฐานความรู้ การบันทึก และการตั้งค่า ไม่สามารถยกเลิกได้';

  @override
  String deleteAccountTypeName(Object name) {
    return 'พิมพ์ \"$name\" เพื่อยืนยัน';
  }

  @override
  String get deleteAccountTypeHint => 'ป้อนชื่อผู้ใช้เพื่อยืนยัน';

  @override
  String get llmConsentTitle => 'ความยินยอมในการแชร์ข้อมูล';

  @override
  String llmConsentMessage(Object provider) {
    return 'เพื่อเปิดใช้งานฟีเจอร์ AI Memex ต้องส่งข้อมูลของคุณไปยัง $provider เพื่อประมวลผล รวมถึง:\n\n• ข้อความที่คุณป้อน (บันทึก การถอดเสียง)\n• ข้อมูลเมตาของรูปภาพและข้อความที่สกัด (OCR)\n• สรุปสุขภาพและฟิตเนส\n• เนื้อหาบัตรไทม์ไลน์\n\nข้อมูลของคุณถูกส่งตรงจากอุปกรณ์ไปยัง $provider Memex ไม่เก็บหรือส่งต่อข้อมูลผ่านเซิร์ฟเวอร์อื่น\n\nโปรดอ่านนโยบายความเป็นส่วนตัวของ $provider เกี่ยวกับการจัดการข้อมูลของคุณ\n\nคุณยอมรับที่จะส่งข้อมูลไปยัง $provider เพื่อประมวลผล AI หรือไม่?';
  }

  @override
  String get llmConsentAgree => 'ยอมรับ';

  @override
  String get llmConsentDecline => 'ปฏิเสธ';

  @override
  String get customAgents => 'Agent แบบกำหนดเอง';

  @override
  String get noCustomAgents => 'ยังไม่ได้กำหนด agent แบบกำหนดเอง';

  @override
  String get deleteAgent => 'ลบ Agent';

  @override
  String deleteAgentConfirm(Object name) {
    return 'ลบ agent แบบกำหนดเอง \"$name\"?';
  }

  @override
  String get deleted => 'ลบแล้ว';

  @override
  String get saved => 'บันทึกแล้ว';

  @override
  String get newAgent => 'Agent ใหม่';

  @override
  String get editAgent => 'แก้ไข Agent';

  @override
  String get agentName => 'ชื่อ Agent';

  @override
  String get agentNameHint => 'my-custom-agent';

  @override
  String get agentNameRequired => 'จำเป็น';

  @override
  String get agentNameInvalid => 'ใช้ได้เฉพาะตัวอักษร ตัวเลข และขีดกลาง';

  @override
  String get agentNameExists => 'ชื่อนี้มีอยู่แล้ว';

  @override
  String get hostAgentType => 'ประเภท Host Agent';

  @override
  String get skillDirectory => 'ไดเรกทอรี Skill';

  @override
  String get skillDirInvalid =>
      'ต้องเป็นเส้นทางสัมพัทธ์ (ไม่มี / หรือ .. นำหน้า)';

  @override
  String get workingDirectory => 'ไดเรกทอรีทำงาน (ไม่บังคับ)';

  @override
  String get workingDirectoryHint =>
      'เว้นว่างเพื่อใช้ค่าเริ่มต้นของพื้นที่ทำงาน';

  @override
  String get llmConfig => 'การกำหนดค่า LLM';

  @override
  String get eventType => 'ประเภทกิจกรรม';

  @override
  String get executionMode => 'โหมดการทำงาน';

  @override
  String get executionModeAsync => 'อะซิงโครนัส';

  @override
  String get executionModeSync => 'ซิงโครนัส';

  @override
  String get dependsOn => 'ขึ้นกับ';

  @override
  String get dependsOnHint => 'เลือกการพึ่งพา';

  @override
  String get priority => 'ลำดับความสำคัญ';

  @override
  String get maxRetries => 'จำนวนลองใหม่สูงสุด';

  @override
  String get systemPromptLabel => 'System Prompt (ไม่บังคับ)';

  @override
  String get systemPromptHint =>
      'คำสั่งเพิ่มเติมที่ต่อท้าย prompt ของ host agent';

  @override
  String get eventSerializer => 'Event Serializer';

  @override
  String get eventSerializerDefault => 'ค่าเริ่มต้น (XML)';

  @override
  String get enabledLabel => 'เปิดใช้งาน';

  @override
  String get skillsManagement => 'การจัดการ Skills';

  @override
  String get skillsManagementEmpty => 'ยังไม่มี skill';

  @override
  String get downloadSkill => 'ดาวน์โหลด Skill';

  @override
  String get downloadFile => 'ดาวน์โหลดไฟล์';

  @override
  String get downloading => 'กำลังดาวน์โหลด...';

  @override
  String get downloadSuccess => 'ดาวน์โหลด Skill สำเร็จ';

  @override
  String downloadFailed(Object error) {
    return 'ดาวน์โหลดล้มเหลว: $error';
  }

  @override
  String get deleteConfirm => 'ยืนยันการลบ';

  @override
  String deleteConfirmMessage(String name) {
    return 'คุณแน่ใจหรือไม่ว่าต้องการลบ \"$name\"?';
  }

  @override
  String get invalidUrl => 'โปรดป้อน URL ที่ถูกต้อง';

  @override
  String get urlHint => 'https://example.com/skill.zip';

  @override
  String get newFolder => 'โฟลเดอร์ใหม่';

  @override
  String get newFile => 'ไฟล์ใหม่';

  @override
  String get folderName => 'ชื่อโฟลเดอร์';

  @override
  String get fileName => 'ชื่อไฟล์';

  @override
  String get nameRequired => 'ต้องระบุชื่อ';

  @override
  String get nameInvalid => 'ชื่อต้องไม่มี / หรือ ..';

  @override
  String createFailed(Object error) {
    return 'สร้างล้มเหลว: $error';
  }

  @override
  String get fileContent => 'เนื้อหาไฟล์';

  @override
  String get saveSuccess => 'บันทึกสำเร็จ';

  @override
  String downloadToCurrentDir(String dir) {
    return 'ไฟล์ ZIP จะถูกแตกไปยังไดเรกทอรีปัจจุบัน: $dir';
  }

  @override
  String get privacyPolicy => 'นโยบายความเป็นส่วนตัว';

  @override
  String get privacyPolicyDesc => 'Memex จัดการข้อมูลของคุณอย่างไร';

  @override
  String get llmAuthError =>
      'การยืนยันตัวตน API ล้มเหลว โปรดตรวจสอบการกำหนดค่า LLM ในการตั้งค่า';

  @override
  String get llmBadRequestError =>
      'คำขอถูกปฏิเสธโดยผู้ให้บริการ LLM รูปแบบข้อมูลอาจไม่รองรับโดยโมเดลปัจจุบัน';

  @override
  String get llmRateLimitError =>
      'เกินขีดจำกัดอัตรา API โปรดลองอีกครั้งในภายหลัง';

  @override
  String get llmServerError =>
      'บริการ LLM ไม่พร้อมใช้งานชั่วคราว โปรดลองอีกครั้งในภายหลัง';

  @override
  String get llmNetworkError =>
      'การเชื่อมต่อเครือข่ายล้มเหลว โปรดตรวจสอบการเชื่อมต่ออินเทอร์เน็ต';

  @override
  String get llmUnknownError =>
      'เกิดข้อผิดพลาดที่ไม่คาดคิดขณะประมวลผลเนื้อหาของคุณ';

  @override
  String get llmErrorDialogTitle => 'ประมวลผลล้มเหลว';

  @override
  String get goToModelConfig => 'ไปที่การตั้งค่า';

  @override
  String get speechModelDownloadTitle => 'ดาวน์โหลดโมเดลเสียงพูด';

  @override
  String speechModelDownloadDesc(Object sizeMB) {
    return 'ต้องดาวน์โหลดโมเดลครั้งเดียว (~${sizeMB}MB)\n\nเมื่อดาวน์โหลดแล้ว การถอดเสียงจะทำงานทั้งหมดในเครื่อง';
  }

  @override
  String get speechModelStartDownload => 'เริ่มดาวน์โหลด';

  @override
  String get speechModelChooseSource => 'เลือกแหล่งดาวน์โหลด:';

  @override
  String get speechModelChinaMirror => '🇨🇳 China Mirror (เร็วกว่าในจีน)';

  @override
  String get speechModelGithub => '🌐 GitHub (ทั่วโลก)';

  @override
  String get speechModelDownloading => 'กำลังดาวน์โหลดโมเดล...';

  @override
  String get speechModelConnecting => 'กำลังเชื่อมต่อ...';

  @override
  String get deleteSpeechModel => 'ลบโมเดลเสียงพูด';

  @override
  String get confirmDeleteSpeechModelMessage =>
      'ลบไฟล์โมเดลการรู้จำเสียงพูดในเครื่องที่ดาวน์โหลดแล้ว? จะดาวน์โหลดอีกครั้งเมื่อใช้ speech-to-text ในเครื่องครั้งถัดไป';

  @override
  String get speechModelDeletedSuccess => 'ลบไฟล์โมเดลเสียงพูดแล้ว';

  @override
  String get speechModelNotDownloaded => 'ไม่พบไฟล์โมเดลเสียงพูดที่ดาวน์โหลด';

  @override
  String speechModelDeleteFailed(Object error) {
    return 'ลบไฟล์โมเดลเสียงพูดล้มเหลว: $error';
  }

  @override
  String get speechTranscribing => 'กำลังรู้จำ...';

  @override
  String get speechNoResult => 'ไม่ตรวจพบเสียงพูด';

  @override
  String get useLocalSpeechToTextTitle => 'ใช้ speech to text ในเครื่อง';

  @override
  String get useLocalSpeechToTextDesc =>
      'เมื่อเปิดใช้งาน เสียงจะถอดในเครื่องก่อนส่ง — มีประโยชน์สำหรับโมเดลที่ไม่รองรับการป้อนเสียง เมื่อปิด จะส่งเสียงต้นฉบับตรงไปยังโมเดล';

  @override
  String get pendingAiProcessingHint => 'ตั้งค่าโมเดล AI เพื่อประมวลผล';

  @override
  String get demoWelcome =>
      'ยินดีต้อนรับสู่ Memex!\nมาทัวร์สั้นๆ ดูว่า AI ช่วยบันทึกของคุณได้อย่างไร';

  @override
  String get demoTapAdd => 'แตะที่นี่เพื่อสร้างบันทึกแรกของคุณ';

  @override
  String get demoTapSend => 'แตะเพื่อส่งบันทึกแรกของคุณ';

  @override
  String get demoTapCard => 'แตะเพื่อดูว่า AI จัดระเบียบบันทึกของคุณอย่างไร';

  @override
  String get demoDetailHint =>
      'นี่คือรายละเอียดบันทึกที่ AI จัดระเบียบให้คุณ เลื่อนดู แล้วกลับเพื่อดำเนินการทัวร์ต่อ';

  @override
  String get demoTapInsight => 'แตะเพื่อดูข้อมูลเชิงลึกที่ AI สร้าง';

  @override
  String get demoTapInsightUpdate =>
      'แตะเพื่อสร้างข้อมูลเชิงลึกจากบันทึกของคุณ';

  @override
  String get demoTapKnowledge => 'ตรวจสอบไฟล์ความรู้ที่จัดระเบียบอัตโนมัติ';

  @override
  String get demoDone => 'เริ่มบันทึกชีวิตของคุณ';

  @override
  String get demoStartTour => 'เริ่มทัวร์';

  @override
  String get demoGetStarted => 'เริ่มต้น';

  @override
  String get demoSkip => 'ข้าม';

  @override
  String get demoPrefillText => 'สวัสดี Memex! นี่คือบันทึกแรกของฉัน 🎉';

  @override
  String get visionBadge => 'Vision';

  @override
  String get notMultimodalHint =>
      'Memex พึ่งพาความสามารถโมเดลมัลติโมดัลสำหรับการวิเคราะห์สื่อ หากบันทึกของคุณมีรูปภาพ โปรดตรวจสอบว่าโมเดลที่กำหนดรองรับการป้อนรูปภาพ';

  @override
  String get defaultModelPrefix => 'ค่าเริ่มต้น';

  @override
  String get recommendedBadge => 'แนะนำ';

  @override
  String get readOnlyBadge => 'CHAT';

  @override
  String get switchCompanion => 'สลับคู่หู';

  @override
  String get personaChatInputHint => 'พิมพ์ข้อความ...';

  @override
  String get today => 'วันนี้';

  @override
  String get tomorrow => 'พรุ่งนี้';

  @override
  String get yesterday => 'เมื่อวาน';

  @override
  String get showInsightTextTitle => 'แสดงความคิดเห็นข้อมูลเชิงลึก Memex';

  @override
  String get showInsightTextDesc =>
      'แสดงข้อมูลเชิงลึก Memex เป็นความคิดเห็นปักหมุดในส่วนความคิดเห็นรายละเอียดบัตรหรือไม่';

  @override
  String get enableCharacterCommentTitle => 'ความคิดเห็นอัตโนมัติของตัวละคร';

  @override
  String get enableCharacterCommentDesc =>
      'ตัวละครจะแสดงความคิดเห็นอัตโนมัติเมื่อมีบันทึกใหม่';

  @override
  String get maxCommentCharactersTitle => 'ตัวอักษรความคิดเห็นสูงสุด';

  @override
  String get maxCommentCharactersDesc =>
      'จำนวนตัวอักษรสูงสุดที่แสดงความคิดเห็นในแต่ละบันทึก';

  @override
  String replyTo(String name) {
    return 'ตอบกลับ $name';
  }

  @override
  String get cdnSignalsComments => 'ได้รับการตอบกลับใหม่';

  @override
  String get cdnSignalsInsight => 'สร้างข้อมูลเชิงลึกใหม่แล้ว';

  @override
  String get cdnSignalsBoth => 'การตอบกลับและข้อมูลเชิงลึกใหม่';

  @override
  String get untitledCard => 'บัตรไม่มีชื่อ';

  @override
  String get locationContextTitle => 'บริบทตำแหน่ง';

  @override
  String get locationContextDescription =>
      'บริบทเมืองและย่านปัจจุบันสำหรับแชท agent';

  @override
  String get locationContextAttachTitle => 'แนบตำแหน่งปัจจุบันในแชท';

  @override
  String get locationContextAttachDesc =>
      'ใช้ GPS ของอุปกรณ์และ reverse geocoding เพื่อให้บริบทเมือง เขต และย่านแก่ agent';

  @override
  String get reverseGeocodingProvider => 'ผู้ให้บริการ reverse geocoding';

  @override
  String get amapProviderName => 'Amap';

  @override
  String get amapApiKey => 'Amap API Key';

  @override
  String get amapGcj02Note =>
      'Amap ใช้พิกัด GCJ-02 จะแปลง GPS ของอุปกรณ์ก่อน reverse geocoding';

  @override
  String get contextGranularity => 'ความละเอียดของบริบท';

  @override
  String get granularityCity => 'เมือง';

  @override
  String get granularityDistrict => 'เขต';

  @override
  String get granularityNeighborhood => 'ย่าน';

  @override
  String get granularityStreet => 'ถนน';

  @override
  String get granularityFullAddress => 'ที่อยู่เต็ม (ตัวเลือก)';

  @override
  String get locationFreshness => 'ความสดของตำแหน่ง';

  @override
  String minutesShort(int minutes) {
    return '$minutes นาที';
  }

  @override
  String get oneHour => '1 ชั่วโมง';

  @override
  String get testCurrentLocation => 'ทดสอบตำแหน่งปัจจุบัน';

  @override
  String locationTestFailed(String error) {
    return 'ล้มเหลว: $error';
  }

  @override
  String get locationDebugGps => 'GPS';

  @override
  String get locationDebugReverseGeocode => 'Reverse geocode';

  @override
  String get locationDebugProvider => 'ผู้ให้บริการ';

  @override
  String get locationDebugAgentContext => 'บริบท agent';

  @override
  String get locationDebugSource => 'แหล่งที่มา';

  @override
  String get locationDebugAddressSummary => 'สรุปที่อยู่';

  @override
  String get locationDebugFullAddress => 'ที่อยู่เต็ม';

  @override
  String get locationDebugCoordinates => 'พิกัด';

  @override
  String get locationDebugAccuracy => 'ความแม่นยำ';

  @override
  String get locationDebugReason => 'เหตุผล';

  @override
  String get locationDebugOk => 'OK';

  @override
  String get locationDebugUnavailable => 'ไม่พร้อมใช้งาน';

  @override
  String get locationDebugInjected => 'แนบแล้ว';

  @override
  String get locationDebugNotInjected => 'ยังไม่แนบ';

  @override
  String get locationStatusUpdatedAt => 'อัปเดต';

  @override
  String get locationStatusSuccessTitle => 'ตำแหน่งปัจจุบันพร้อมใช้งาน';

  @override
  String get locationStatusSuccessBody =>
      'Memex สามารถแนบสรุปตำแหน่งนี้เมื่อบริบทตำแหน่งเกี่ยวข้อง';

  @override
  String get locationStatusApproximateTitle => 'ตำแหน่งโดยประมาณเท่านั้น';

  @override
  String get locationStatusApproximateBody =>
      'ความแม่นยำอยู่ในระดับเมืองหรือพื้นที่ คุณสามารถใช้งานต่อหรือเปิด Precise Location ในการตั้งค่าระบบเพื่อบริบทที่ละเอียดขึ้น';

  @override
  String get locationStatusServiceDisabledTitle => 'ปิดบริการตำแหน่งระบบ';

  @override
  String get locationStatusServiceDisabledBody =>
      'Memex ใช้เฉพาะ GPS ของอุปกรณ์และจะไม่อนุมานตำแหน่งจากเครือข่ายหรือ IP บน Android เปิดการตั้งค่าตำแหน่ง บน iOS เปิด Settings > Privacy & Security > Location Services';

  @override
  String get locationStatusPermissionDeniedTitle => 'ต้องการสิทธิ์ตำแหน่ง';

  @override
  String get locationStatusPermissionDeniedBody =>
      'อนุญาตให้ Memex ใช้ตำแหน่งขณะทดสอบหรือเมื่อต้องการบริบทตำแหน่ง ไม่ขอสิทธิ์ตลอดเวลา';

  @override
  String get locationStatusPermissionForeverTitle => 'สิทธิ์ตำแหน่งถูกบล็อก';

  @override
  String get locationStatusPermissionForeverBody =>
      'เปิดการตั้งค่าแอปและอนุญาตตำแหน่งสำหรับ Memex บน iOS ใช้ While Using the App ก็เพียงพอ';

  @override
  String get locationStatusDisabledTitle => 'ปิดบริบทตำแหน่ง';

  @override
  String get locationStatusDisabledBody =>
      'เปิดสวิตช์ด้านบนและบันทึกเมื่อต้องการให้ Memex แนบตำแหน่งอุปกรณ์ในบริบท agent';

  @override
  String get locationStatusGeocodeUnavailableTitle =>
      'GPS ใช้งานได้ แต่ค้นหาที่อยู่ล้มเหลว';

  @override
  String get locationStatusGeocodeUnavailableBody =>
      'Memex มีพิกัดแต่จะไม่แนบบริบท GPS เท่านั้นใน agent ตรวจสอบผู้ให้บริการ reverse geocoding แล้วลองอีกครั้ง';

  @override
  String get locationStatusUnavailableTitle => 'ตำแหน่งไม่พร้อมใช้งาน';

  @override
  String get locationStatusUnavailableBody =>
      'ตรวจสอบบริการตำแหน่งระบบและสิทธิ์แอป แล้วทดสอบอีกครั้ง';

  @override
  String get allowLocationPermissionButton => 'อนุญาตสิทธิ์ตำแหน่ง';

  @override
  String get openAppSettingsButton => 'เปิดการตั้งค่าแอป';

  @override
  String get openLocationSettingsButton => 'เปิดการตั้งค่าตำแหน่ง';

  @override
  String get locationSettingsOpenFailed => 'ไม่สามารถเปิดการตั้งค่าระบบ';

  @override
  String locationActionFailed(String error) {
    return 'การดำเนินการตำแหน่งล้มเหลว: $error';
  }

  @override
  String get settingsSearchPlaceholder => 'ค้นหาการตั้งค่า...';

  @override
  String get settingsSearchEmpty => 'ไม่พบการตั้งค่าที่ตรงกัน';

  @override
  String get importCharacterCard => 'นำเข้าบัตรตัวละคร';

  @override
  String get firstMessageLabel => 'ข้อความแรก';

  @override
  String get firstMessageHint =>
      'ข้อความทักทายเมื่อเริ่มการสนทนาครั้งแรก (ไม่บังคับ)';

  @override
  String get systemPromptOverrideLabel => 'แทนที่ System Prompt';

  @override
  String get systemPromptOverrideHint =>
      'แทนที่ system prompt เริ่มต้น (ขั้นสูง ไม่บังคับ)';

  @override
  String get postHistoryInstructionsLabel => 'คำสั่งหลังประวัติ';

  @override
  String get postHistoryInstructionsHint =>
      'คำสั่งที่แทรกหลังประวัติแชท ก่อนตอบ (ไม่บังคับ)';

  @override
  String get mesExampleLabel => 'ตัวอย่างข้อความ';

  @override
  String get mesExampleHint => 'ตัวอย่างบทสนทนาแสดงสไตล์ตัวละคร (ไม่บังคับ)';

  @override
  String get worldBookTitle => 'World Book';

  @override
  String get worldBookSubtitle =>
      'ความรู้พื้นหลังที่แทรกเมื่อคำสำคัญถูกทริกเกอร์';

  @override
  String get characterMemoryTitle => 'ความทรงจำตัวละคร';

  @override
  String get characterMemorySubtitle =>
      'พลวัตความสัมพันธ์และความทรงจำในการโต้ตอบระหว่างตัวละครและผู้ใช้';

  @override
  String get addTooltip => 'เพิ่ม';

  @override
  String get constantBadge => 'ค่าคงที่';

  @override
  String worldEntryFallbackName(Object index) {
    return 'รายการ $index';
  }

  @override
  String keywordsPrefix(Object keys) {
    return 'คำสำคัญ: $keys';
  }

  @override
  String memoryFallbackName(Object index) {
    return 'ความทรงจำ $index';
  }

  @override
  String get addWorldEntry => 'เพิ่มรายการ World Book';

  @override
  String get editWorldEntry => 'แก้ไขรายการ World Book';

  @override
  String get commentTitleLabel => 'ความคิดเห็น / หัวข้อ';

  @override
  String get entryDescriptionHint => 'คำอธิบายรายการ (ไม่บังคับ)';

  @override
  String get triggerKeywordsLabel => 'คำสำคัญทริกเกอร์';

  @override
  String get triggerKeywordsHint =>
      'คั่นด้วยเครื่องหมายจุลภาค เช่น: magic, spell';

  @override
  String get contentLabel => 'เนื้อหา';

  @override
  String get worldEntryContentHint =>
      'ความรู้พื้นหลังที่แทรกเมื่อคำสำคัญทริกเกอร์';

  @override
  String get enabledCheckbox => 'เปิดใช้งาน';

  @override
  String get addMemory => 'เพิ่มความทรงจำ';

  @override
  String get editMemory => 'แก้ไขความทรงจำ';

  @override
  String get memoryLabelField => 'ป้ายกำกับ';

  @override
  String get memoryLabelHint => 'ตัวระบุเฉพาะ เช่น: ความชอบชื่อ';

  @override
  String get memoryContentHint => 'เนื้อหาความทรงจำ';

  @override
  String get salienceLabel => 'ความสำคัญ: ';

  @override
  String get labelCannotBeEmpty => 'ป้ายกำกับต้องไม่ว่าง';

  @override
  String importSuccess(Object name) {
    return 'นำเข้า $name สำเร็จ';
  }

  @override
  String importFailed(Object error) {
    return 'นำเข้าล้มเหลว: $error';
  }

  @override
  String get supportedFormats => 'รูปแบบที่รองรับ';

  @override
  String get tavernImportDescription =>
      '• บัตรตัวละคร SillyTavern V2 (.json)\n• รูป PNG ที่ฝังบัตร (.png)\n\nฟิลด์เช่น persona, World Book ฯลฯ จะถูกแมปไปยังรูปแบบตัวละคร Memex อัตโนมัติ';

  @override
  String get pickCharacterFile => 'เลือกไฟล์ตัวละคร';

  @override
  String get repickFile => 'เลือกไฟล์อื่น';

  @override
  String get personaSettingSection => 'บุคลิก';

  @override
  String get systemPromptSection => 'System Prompt';

  @override
  String worldEntriesCount(Object count) {
    return 'World Book: $count รายการ';
  }

  @override
  String fileLabel(Object filename) {
    return 'ไฟล์: $filename';
  }

  @override
  String conflictWarning(Object names) {
    return 'มีตัวละครชื่อเดียวกันอยู่แล้ว: $names การนำเข้าจะสร้างตัวละครใหม่โดยไม่เขียนทับตัวที่มีอยู่';
  }

  @override
  String get setPrimaryCompanionTitle => 'ตั้งเป็นคู่หูหลัก';

  @override
  String get setPrimaryCompanionSubtitle =>
      'ตั้งเป็นคู่หูหลักอัตโนมัติหลังนำเข้า';

  @override
  String get confirmImport => 'ยืนยันการนำเข้า';

  @override
  String get chatBackground => 'พื้นหลังแชท';

  @override
  String get chooseChatBackgroundImage => 'เลือกรูปพื้นหลัง';

  @override
  String get earlyUpdateSettingsTitle => 'อัปเดต Early access';

  @override
  String get earlyUpdateSettingsDesc =>
      'ตรวจสอบ GitHub pre-releases สำหรับ Early APK ที่ตรงกัน ดาวน์โหลด และส่งให้ตัวติดตั้ง Android';

  @override
  String get earlyUpdateUnsupported =>
      'อัปเดต Early ใช้ได้เฉพาะใน Android Early build';

  @override
  String get earlyUpdateAutoCheckTitle => 'ตรวจสอบอัปเดตอัตโนมัติ';

  @override
  String get earlyUpdateAutoCheckDesc =>
      'ตรวจสอบเมื่อเริ่มต้นได้มากที่สุดทุก 12 ชั่วโมง';

  @override
  String get earlyUpdateWifiOnlyTitle => 'ดาวน์โหลดเฉพาะ Wi-Fi';

  @override
  String get earlyUpdateWifiOnlyDesc =>
      'ข้ามการดาวน์โหลดอัปเดตเมื่อใช้ข้อมูลมือถือ';

  @override
  String get earlyUpdateAutoInstallTitle => 'ดาวน์โหลดและติดตั้งอัตโนมัติ';

  @override
  String get earlyUpdateAutoInstallDesc =>
      'เมื่อพบ build ใหม่ จะดาวน์โหลดและเปิดตัวติดตั้ง Android อัตโนมัติ';

  @override
  String get earlyUpdateCheckNow => 'ตรวจสอบตอนนี้';

  @override
  String get earlyUpdateChecking => 'กำลังตรวจสอบ GitHub pre-releases...';

  @override
  String get earlyUpdateSkippedMobile => 'ข้ามเพราะเปิดดาวน์โหลดเฉพาะ Wi-Fi';

  @override
  String get earlyUpdateNoUpdate => 'คุณใช้ Early build ล่าสุดอยู่แล้ว';

  @override
  String earlyUpdateFound(Object version, Object build) {
    return 'มี Early build $version+$build';
  }

  @override
  String get earlyUpdateDownloadAndInstall => 'ดาวน์โหลดและติดตั้ง';

  @override
  String get earlyUpdateDownloadInProgress => 'กำลังดาวน์โหลดอัปเดต...';

  @override
  String earlyUpdateDownloadingPercent(Object percent) {
    return 'กำลังดาวน์โหลดอัปเดต: $percent%';
  }

  @override
  String get earlyUpdateDownloadReadyToInstall =>
      'ดาวน์โหลดแพ็กเกจอัปเดตแล้ว พร้อมติดตั้ง';

  @override
  String get earlyUpdateInstallDownloadedPackage =>
      'ติดตั้งแพ็กเกจที่ดาวน์โหลด';

  @override
  String get earlyUpdateClearDownloadedPackage => 'ล้างแพ็กเกจที่ดาวน์โหลด';

  @override
  String get earlyUpdateClearDownloadedPackageSuccess =>
      'ล้างแพ็กเกจอัปเดตที่ดาวน์โหลดแล้ว';

  @override
  String get earlyUpdateInstallStarted => 'เปิดตัวติดตั้ง Android แล้ว';

  @override
  String get earlyUpdateInstallPermissionRequired =>
      'อนุญาตให้ Memex ติดตั้งแอปที่ไม่รู้จัก แล้วแตะดาวน์โหลดและติดตั้งอีกครั้ง';

  @override
  String earlyUpdateLastChecked(Object time) {
    return 'ตรวจสอบล่าสุด: $time';
  }

  @override
  String earlyUpdateCheckFailed(Object error) {
    return 'ตรวจสอบอัปเดตล้มเหลว: $error';
  }

  @override
  String get earlyUpdateDialogTitle => 'มีอัปเดต Early';

  @override
  String get earlyUpdateReleaseNotes => 'บันทึกการเผยแพร่';

  @override
  String get dismissAllNotifications => 'ล้างทั้งหมด';

  @override
  String get dismissByType => 'ล้างตามประเภท';

  @override
  String get dismissTypeSystemAction => 'การเตือนและกิจกรรม';

  @override
  String get dismissTypeClarification => 'การชี้แจง';

  @override
  String get dismissTypeCardUpdate => 'อัปเดตบัตร';

  @override
  String dismissedCount(Object count) {
    return 'ล้างแล้ว $count รายการ';
  }

  @override
  String get dataImportTitle => 'นำเข้าไฟล์';

  @override
  String get dataImportSettingsDescription =>
      'นำไฟล์เก่าเข้า Memex แล้วตัดสินใจว่าจะจัดระเบียบหรือไม่';

  @override
  String get dataImportDescription =>
      'เลือกบันทึกเก่า บันทึกที่ส่งออก เอกสาร หรือไฟล์ ZIP Memex จะบันทึกสำเนาก่อนและไม่แตะต้องไฟล์ต้นฉบับ หลังนำเข้า คุณสามารถตัดสินใจว่า Memex ควรช่วยจัดระเบียบหรือไม่';

  @override
  String get dataImportSelectFiles => 'เลือกไฟล์ที่จะนำเข้า';

  @override
  String get dataImportImporting => 'กำลังบันทึกไฟล์...';

  @override
  String get dataImportSuccess => 'บันทึกไฟล์ใน Memex แล้ว';

  @override
  String get dataImportOnlyStored => 'บันทึกไฟล์แล้ว ยังไม่เริ่มการจัดระเบียบ';

  @override
  String get dataImportQueued => 'Memex จะจัดระเบียบการนำเข้านี้ในพื้นหลัง';

  @override
  String get dataImportResultTitle => 'นำเข้าเสร็จสิ้น';

  @override
  String dataImportResultSummary(Object count) {
    return 'บันทึก $count ไฟล์แล้ว คุณสามารถจัดระเบียบตอนนี้หรือเก็บเป็นวัสดุต้นฉบับ';
  }

  @override
  String dataImportRenamedConflicts(Object count) {
    return '$count รายการมีชื่อซ้ำและถูกเปลี่ยนชื่อเพื่อไม่ให้เขียนทับ';
  }

  @override
  String dataImportSkippedUnsafeEntries(Object count) {
    return 'ข้ามรายการในไฟล์บีบอัดที่ผิดปกติ $count รายการ ส่วนที่เหลือนำเข้าตามปกติ';
  }

  @override
  String get dataImportChooseProcessing => 'จัดระเบียบไฟล์เหล่านี้';

  @override
  String get dataImportProcessTitle => 'จัดระเบียบการนำเข้านี้?';

  @override
  String dataImportProcessPrompt(Object count) {
    return 'คุณนำเข้า $count ไฟล์ เลือกว่า Memex ควรจัดระเบียบตอนนี้หรือเก็บต้นฉบับไว้';
  }

  @override
  String get dataImportProcessKnowledgeBase => 'จัดระเบียบลงฐานความรู้';

  @override
  String get dataImportProcessKnowledgeBaseDesc =>
      'เหมาะสำหรับเอกสาร บันทึก วัสดุโครงการ และอ้างอิง Memex จะดึงข้อมูลที่มีประโยชน์และจัดกลุ่มเพื่อใช้ในภายหลัง';

  @override
  String get dataImportProcessTimelineCards => 'สร้างบันทึกไทม์ไลน์';

  @override
  String get dataImportProcessTimelineCardsDesc =>
      'เหมาะสำหรับไดอารี่ บันทึกแชท ประวัติกิจกรรม และการส่งออกเก่า Memex จะแปลงเนื้อหาตามเวลาเป็นบันทึกเมื่อเหมาะสม';

  @override
  String get dataImportImpactNone =>
      'Memex จะเก็บไฟล์ต้นฉบับเท่านั้น จะไม่เริ่มการจัดระเบียบ AI';

  @override
  String get dataImportImpactKnowledgeBase =>
      'Memex จะอ่านไฟล์เหล่านี้และจัดระเบียบข้อมูลระยะยาวที่มีประโยชน์ลงในฐานความรู้ จะไม่สร้างบันทึกไทม์ไลน์โดยอัตโนมัติ';

  @override
  String get dataImportImpactTimelineCards =>
      'Memex จะอ่านไฟล์เหล่านี้และสร้างบันทึกไทม์ไลน์สำหรับเหตุการณ์ในชีวิตหรือประวัติที่มีวันที่เมื่อเหมาะสม จะไม่จัดระเบียบฐานความรู้โดยอัตโนมัติ';

  @override
  String get dataImportImpactBoth =>
      'Memex จะพยายามสร้างบันทึกไทม์ไลน์และจัดระเบียบข้อมูลที่นำกลับมาใช้ได้ลงในฐานความรู้ เหมาะสำหรับคลังส่วนตัวที่สมบูรณ์';

  @override
  String get dataImportFinish => 'เก็บไว้อย่างเดียว';

  @override
  String get noImages => 'ไม่มีรูปภาพ';

  @override
  String get noMessages => 'ไม่มีข้อความ';

  @override
  String get sketchContent => 'เนื้อหาสเก็ตช์';

  @override
  String get emptyFolder => 'โฟลเดอร์ว่าง';

  @override
  String get usernameAlreadyTaken => 'ชื่อผู้ใช้นี้ถูกใช้แล้ว';

  @override
  String get registrationFailed => 'ลงทะเบียนล้มเหลว';

  @override
  String get loginFailed => 'เข้าสู่ระบบล้มเหลว';

  @override
  String get paymentCreationFailed => 'ไม่สามารถเริ่มการชำระเงิน';

  @override
  String get completePayment => 'ชำระเงินให้เสร็จ';

  @override
  String get commentReplyToYou => 'คุณ';

  @override
  String get commentAuthorUser => 'ผู้ใช้';

  @override
  String get commentAuthorAi => 'AI';

  @override
  String get authorizationCancelled => 'ยกเลิกการอนุญาตแล้ว';

  @override
  String timelineWeekNumberLabel(Object week) {
    return 'สัปดาห์ $week';
  }

  @override
  String get timelineWeekLabel => 'สัปดาห์';

  @override
  String get eventCardDefaultTitle => 'กิจกรรม';

  @override
  String get memoryNoLongTermYet => 'ยังไม่มีความทรงจำระยะยาว';

  @override
  String get memoryNoRecentBuffer => 'ไม่มีความทรงจำล่าสุดในบัฟเฟอร์';

  @override
  String get memoryGeneralSubject => 'ทั่วไป';
}
