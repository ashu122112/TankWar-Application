package com.example.TankWar.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.example.TankWar.Model.Projectile;

@Repository
public interface ProjectileRepository extends JpaRepository<Projectile,Integer>{

}
