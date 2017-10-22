package daggerok.counter;

import lombok.RequiredArgsConstructor;
import lombok.val;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
@RequiredArgsConstructor
public class CounterPage {

  final CounterRepository repository;

  @GetMapping
  @Transactional
  public String index(final Model model) {
    val counter = repository.findOrCreate("counter");
    counter.setTotal(counter.getTotal() + 1);
    model.addAttribute("counter", repository.save(counter));
    return "index";
  }
}
