package daggerok;

import lombok.RequiredArgsConstructor;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.core.env.Environment;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.Collections;
import java.util.Map;

@SpringBootApplication
public class AppApplication {

  @RestController
  @RequiredArgsConstructor
  static class ColorPickerResource {

    final Environment environment;

    @GetMapping
    public Map getColor() {
      return Collections.singletonMap("color", environment.getProperty("COLOR", "unknown"));
    }
  }

  public static void main(String[] args) {
    SpringApplication.run(AppApplication.class, args);
  }
}
