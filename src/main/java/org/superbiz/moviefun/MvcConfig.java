package org.superbiz.moviefun;

import org.springframework.boot.web.servlet.ServletRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ViewControllerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurerAdapter;

@Configuration
public class MvcConfig extends WebMvcConfigurerAdapter {
    @Override
    public void addViewControllers(ViewControllerRegistry registry) {
        registry.addViewController("/").setViewName("index");
    }

    @Bean
    public ServletRegistrationBean getServletRegistrationBean (ActionServlet servlet){

        ServletRegistrationBean servletRegistrationBean = new ServletRegistrationBean(servlet);
        servletRegistrationBean.addUrlMappings("/moviefun");
        return servletRegistrationBean;
    }
}
