package daggerok.counter;

import lombok.RequiredArgsConstructor;
import lombok.SneakyThrows;
import lombok.val;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

import java.net.Inet4Address;

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
    setProps(model);
    return "index";
  }

  @SneakyThrows
  private static void setProps(final Model model) {
    val host = Inet4Address.getLocalHost();
    model.addAttribute("host", host.getHostName());
    model.addAttribute("addr", host.getHostAddress());
  }
}
