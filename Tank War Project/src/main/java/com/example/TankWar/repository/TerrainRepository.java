package com.example.TankWar.repository;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.example.TankWar.Model.Terrain;

@Repository
public interface TerrainRepository extends JpaRepository<Terrain,Integer> {

}
