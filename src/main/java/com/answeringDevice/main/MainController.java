package com.answeringDevice.main;

import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;

@Controller
public class MainController {

	@Autowired
	JdbcTemplate jdbcTemplate;

	@RequestMapping(value = "/")
	public String index() {
		return "index";
	}
	
	@ResponseBody
	@RequestMapping(value = "/Query", method = RequestMethod.GET)
	public List toQuery(HttpServletRequest req) {
		String topicName = "%" + req.getParameter("topicName").toString() +"%";
		String sql = "select DISTINCT concat('【题目】:',topicName,'【答案】：',answer)content from Topic where concat(topicName,answer) like ?;";
		List list = jdbcTemplate.queryForList(sql, topicName);
		return list;
	}
}
