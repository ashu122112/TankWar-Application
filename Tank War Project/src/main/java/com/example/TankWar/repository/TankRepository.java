package com.example.TankWar.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.example.TankWar.Model.Tank;

@Repository
public interface TankRepository extends JpaRepository<Tank,Integer>{
	
}
