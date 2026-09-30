package com.example.aigateway.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ViewControllerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

@Configuration
public class WebMvcConfig implements WebMvcConfigurer {

    @Override
    public void addViewControllers(ViewControllerRegistry registry) {
        // Tự động chuyển hướng từ trang chủ (/) sang giao diện Swagger
        registry.addRedirectViewController("/", "/swagger-ui/index.html");
    }
}
