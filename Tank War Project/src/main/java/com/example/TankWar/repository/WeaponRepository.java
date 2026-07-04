package com.example.TankWar.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.example.TankWar.Model.Weapon;

@Repository
public interface WeaponRepository extends JpaRepository<Weapon,Integer>{

}
