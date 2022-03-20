package com.homepage.jksong;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.boot.builder.SpringApplicationBuilder;
import org.springframework.boot.web.servlet.support.SpringBootServletInitializer;

@SpringBootApplication
public class JksongApplication extends ServletInitializer {

    public static void main(String[] args) {
        SpringApplication.run(JksongApplication.class, args);
    }

}
