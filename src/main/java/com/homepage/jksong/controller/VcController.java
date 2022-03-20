package com.homepage.jksong.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
public class VcController {

    @RequestMapping("/vc")
    public String index() {
        return "vc";
    }
}
