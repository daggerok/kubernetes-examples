package daggerok.counter;

import org.springframework.data.repository.PagingAndSortingRepository;
import org.springframework.stereotype.Repository;

import static java.util.Optional.ofNullable;

@Repository
public interface CounterRepository extends PagingAndSortingRepository<Counter, String> {
  default Counter findOrCreate(final String key) {
    return ofNullable(findOne(key))
        .orElse(save(new Counter().setId(key).setTotal(0L)));
  }
}
