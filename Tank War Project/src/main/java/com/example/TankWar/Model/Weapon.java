package com.example.TankWar.Model;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.Table;

@Entity
@Table(name="weapons")
public class Weapon {
	@Id
	@GeneratedValue(strategy=GenerationType.IDENTITY)
	private int id;
	private String type;         
    private int damage;      
    @Column(name = "weapon_range")
    private double range;         
    private double weight;        

    
    public Weapon() {}

    public Weapon(String type, int damage, double range, double weight) {
        this.type = type;
        this.damage = damage;
        this.range = range;
        this.weight = weight;
    }
    
    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public int getDamage() {
        return damage;
    }

    public void setDamage(int damage) {
        this.damage = damage;
    }

    public double getRange() {
        return range;
    }

    public void setRange(double range) {
        this.range = range;
    }

    public double getWeight() {
        return weight;
    }

    public void setWeight(double weight) {
        this.weight = weight;
    }

    
    public double calculateEffectivePower(double initialPower) {
        return initialPower * (1 - weight / 10);
    }
}
