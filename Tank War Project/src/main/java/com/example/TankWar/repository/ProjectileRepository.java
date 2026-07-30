package com.example.tankwar.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.example.tankwar.model.Projectile;

@Repository
public interface ProjectileRepository extends JpaRepository<Projectile,Integer>{

}
