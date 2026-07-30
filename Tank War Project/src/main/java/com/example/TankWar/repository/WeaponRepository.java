package com.example.tankwar.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.example.tankwar.model.Weapon;

@Repository
public interface WeaponRepository extends JpaRepository<Weapon,Integer>{

}
