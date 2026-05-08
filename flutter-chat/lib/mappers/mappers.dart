import 'package:flutter_chat/model/base_model.dart';

abstract class DTOMapper<D, M extends BaseModel> {
  D fromDTO(M dto);

  M toDTO(D model);
}
