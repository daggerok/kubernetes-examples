package daggerok.counter;

import lombok.Data;
import lombok.experimental.Accessors;
import org.springframework.data.annotation.Id;
import org.springframework.data.redis.core.RedisHash;

import java.io.Serializable;

@Data
@RedisHash
@Accessors(chain = true)
public class Counter implements Serializable {

  private static final long serialVersionUID = -2377353749298919423L;

  @Id
  String id;

  Long total;
}
