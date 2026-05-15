import 'package:memex/data/services/schedule_refresh_state_service.dart';
import 'package:memex/domain/models/schedule_refresh_state.dart';
import 'package:memex/utils/logger.dart';
import 'package:memex/utils/user_storage.dart';

final _logger = getLogger('GetScheduleRefreshState');

Future<ScheduleRefreshState> getScheduleRefreshState() async {
  try {
    final userId = await UserStorage.getUserId();
    if (userId == null) return ScheduleRefreshState.clean();
    return ScheduleRefreshStateService.instance.read(userId);
  } catch (e, st) {
    _logger.warning('Failed to get schedule refresh state', e, st);
    return ScheduleRefreshState.clean();
  }
}
